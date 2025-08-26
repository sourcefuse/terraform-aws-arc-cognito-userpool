# Federated Identity Provider Example

This example demonstrates how to create a Cognito User Pool with federated identity providers, allowing users to sign in with their existing accounts from Google, Facebook, Apple, Amazon, SAML, or OIDC providers.

## What This Example Creates

- A Cognito User Pool with email-based authentication
- A hosted UI domain for authentication flows
- Configurable federated identity providers (Google, Facebook, Apple, Amazon, SAML, OIDC)
- An app client configured for OAuth 2.0 flows with federated providers
- Proper attribute mapping between external providers and Cognito
- Support for both native Cognito users and federated users

## Features Demonstrated

- **Multiple Identity Providers**: Support for 6 different types of identity providers
- **Flexible Configuration**: Enable/disable providers as needed
- **Attribute Mapping**: Map external provider attributes to Cognito user attributes
- **Hosted UI Integration**: Seamless integration with Cognito's hosted UI
- **OAuth 2.0 Flows**: Support for authorization code and implicit grant flows
- **Mixed Authentication**: Support both federated and native Cognito users

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Client    │───▶│  Cognito Hosted  │───▶│   Your App      │
│                 │    │       UI         │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  Cognito User    │
                       │      Pool        │
                       └──────────────────┘
                              │
                              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Google    │  │  Facebook   │  │    Apple    │  │   Amazon    │
│   OAuth     │  │   OAuth     │  │   Sign In   │  │   OAuth     │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘

┌─────────────┐  ┌─────────────┐
│    SAML     │  │    OIDC     │
│  Provider   │  │  Provider   │
└─────────────┘  └─────────────┘
```

## Supported Identity Providers

### 1. Google OAuth 2.0
- **Setup Required**: Google Cloud Console project with OAuth 2.0 credentials
- **Scopes**: profile, email, openid
- **Attributes**: email, name, given_name, family_name, picture

### 2. Facebook Login
- **Setup Required**: Facebook App with Facebook Login enabled
- **Permissions**: public_profile, email
- **Attributes**: email, name, first_name, last_name, picture

### 3. Sign in with Apple
- **Setup Required**: Apple Developer account with Services ID configured
- **Scopes**: name, email
- **Attributes**: email, firstName, lastName, name

### 4. Login with Amazon
- **Setup Required**: Amazon Developer account with Security Profile
- **Scopes**: profile
- **Attributes**: email, name, user_id

### 5. SAML 2.0
- **Setup Required**: SAML Identity Provider with metadata URL
- **Attributes**: Configurable based on SAML assertions
- **Use Cases**: Enterprise SSO, Active Directory Federation Services (ADFS)

### 6. OpenID Connect (OIDC)
- **Setup Required**: OIDC-compliant identity provider
- **Scopes**: openid, profile, email
- **Attributes**: Configurable based on OIDC claims

## Usage

### 1. Configure Identity Providers

First, set up your identity providers:

#### Google Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your callback URLs to authorized redirect URIs

#### Facebook Setup
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product
4. Configure Valid OAuth Redirect URIs

#### Apple Setup
1. Go to [Apple Developer](https://developer.apple.com/)
2. Create a Services ID
3. Configure Sign In with Apple
4. Generate and download private key

### 2. Deploy the Infrastructure

1. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit the variables** in `terraform.tfvars`:
   ```hcl
   # Enable Google provider
   enable_google_provider = true
   google_client_id       = "your-google-client-id.apps.googleusercontent.com"
   google_client_secret   = "your-google-client-secret"

   # Enable Facebook provider
   enable_facebook_provider = true
   facebook_app_id          = "your-facebook-app-id"
   facebook_app_secret      = "your-facebook-app-secret"

   # Update callback URLs
   callback_urls = [
     "http://localhost:3000/callback",
     "https://myapp.example.com/callback"
   ]
   ```

3. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Update provider configurations** with the Cognito callback URLs:
   - Google: Add `https://<HOSTED_UI_DOMAIN>/oauth2/idpresponse` to authorized redirect URIs
   - Facebook: Add the same URL to Valid OAuth Redirect URIs
   - Apple: Configure the same URL in your Services ID

## Configuration Examples

### Google Provider Configuration

```hcl
enable_google_provider = true
google_client_id       = "123456789-abcdef.apps.googleusercontent.com"
google_client_secret   = "your-google-client-secret"
google_scopes         = ["profile", "email", "openid"]

# Custom attribute mapping
google_attribute_mapping = {
  email             = "email"
  family_name       = "family_name"
  given_name        = "given_name"
  name              = "name"
  picture           = "picture"
  preferred_username = "sub"
  username          = "sub"
}
```

### Facebook Provider Configuration

```hcl
enable_facebook_provider = true
facebook_app_id          = "1234567890123456"
facebook_app_secret      = "your-facebook-app-secret"
facebook_scopes          = ["public_profile", "email"]

# Custom attribute mapping
facebook_attribute_mapping = {
  email             = "email"
  family_name       = "last_name"
  given_name        = "first_name"
  name              = "name"
  picture           = "picture"
  preferred_username = "id"
  username          = "id"
}
```

### SAML Provider Configuration

```hcl
enable_saml_provider = true
saml_provider_name   = "CompanySSO"
saml_metadata_url    = "https://your-company.com/saml/metadata"

# SAML attribute mapping
saml_attribute_mapping = {
  email             = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  family_name       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
  given_name        = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
  name              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  preferred_username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  username          = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
}
```

## Testing Federated Authentication

After deployment, test each provider:

1. **Get the hosted UI URL**:
   ```bash
   terraform output hosted_ui_url
   ```

2. **Test provider-specific login URLs**:
   ```bash
   # Google login
   terraform output google_login_url

   # Facebook login
   terraform output facebook_login_url

   # Apple login
   terraform output apple_login_url
   ```

3. **Test the authentication flow**:
   - Visit the provider-specific login URL
   - Authenticate with the external provider
   - Verify successful redirect to your callback URL
   - Check that user attributes are properly mapped

## Integration with Applications

### Single-Page Applications

```javascript
import { Amplify, Auth } from 'aws-amplify';

// Configure Amplify
Amplify.configure({
  Auth: {
    region: '<AWS_REGION>',
    userPoolId: '<USER_POOL_ID>',
    userPoolWebClientId: '<CLIENT_ID>',
    oauth: {
      domain: '<HOSTED_UI_DOMAIN>',
      scope: ['email', 'openid', 'profile'],
      redirectSignIn: 'http://localhost:3000/callback',
      redirectSignOut: 'http://localhost:3000/logout',
      responseType: 'code'
    }
  }
});

// Sign in with specific provider
Auth.federatedSignIn({provider: 'Google'});
Auth.federatedSignIn({provider: 'Facebook'});
Auth.federatedSignIn({provider: 'SignInWithApple'});

// Sign in with hosted UI (shows all providers)
Auth.federatedSignIn();

// Get current user (works for both federated and Cognito users)
Auth.currentAuthenticatedUser()
  .then(user => {
    console.log('User:', user);
    console.log('Identity Provider:', user.attributes.identities);
  })
  .catch(err => console.log(err));
```

### Server-Side Applications

```javascript
// Node.js example
const express = require('express');
const axios = require('axios');
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const app = express();

// JWKS client for token verification
const client = jwksClient({
  jwksUri: '<JWKS_URI>'
});

// Redirect to specific provider
app.get('/login/:provider', (req, res) => {
  const { provider } = req.params;
  const authUrl = `https://<HOSTED_UI_DOMAIN>/oauth2/authorize?identity_provider=${provider}&redirect_uri=<CALLBACK_URL>&response_type=code&client_id=<CLIENT_ID>&scope=email+openid+profile`;
  res.redirect(authUrl);
});

// Handle callback
app.get('/callback', async (req, res) => {
  const { code } = req.query;

  try {
    // Exchange code for tokens
    const tokenResponse = await axios.post(`https://<HOSTED_UI_DOMAIN>/oauth2/token`, {
      grant_type: 'authorization_code',
      client_id: '<CLIENT_ID>',
      code: code,
      redirect_uri: '<CALLBACK_URL>'
    });

    const { access_token, id_token } = tokenResponse.data;

    // Verify and decode ID token
    const decoded = jwt.decode(id_token, { complete: true });
    const kid = decoded.header.kid;

    const key = await client.getSigningKey(kid);
    const signingKey = key.getPublicKey();

    const verified = jwt.verify(id_token, signingKey);

    console.log('User info:', verified);
    console.log('Identity provider:', verified.identities);

    res.redirect('/dashboard');
  } catch (error) {
    console.error('Authentication failed:', error);
    res.redirect('/login');
  }
});
```

## User Attribute Mapping

### Understanding Attribute Mapping

Attribute mapping defines how user information from external providers maps to Cognito user attributes:

```hcl
# Example: Google to Cognito mapping
google_attribute_mapping = {
  email             = "email"           # Google email → Cognito email
  family_name       = "family_name"     # Google family_name → Cognito family_name
  given_name        = "given_name"      # Google given_name → Cognito given_name
  name              = "name"            # Google name → Cognito name
  picture           = "picture"         # Google picture → Cognito picture
  preferred_username = "sub"            # Google sub → Cognito preferred_username
  username          = "sub"             # Google sub → Cognito username (unique ID)
}
```

### Custom Attributes

You can also map to custom attributes:

```hcl
# Add custom attributes to the user pool
schema = [
  {
    attribute_data_type = "String"
    name               = "department"
    mutable            = true
    required           = false
    string_attribute_constraints = {
      max_length = "256"
      min_length = "1"
    }
  }
]

# Map SAML attribute to custom attribute
saml_attribute_mapping = {
  "custom:department" = "http://schemas.company.com/identity/claims/department"
}
```

## Security Considerations

### 1. Provider Configuration Security
- **Client Secrets**: Store securely, never commit to version control
- **Callback URLs**: Use HTTPS in production, validate redirect URIs
- **Scopes**: Request only necessary permissions from external providers

### 2. Token Security
- **JWT Verification**: Always verify JWT tokens using JWKS
- **Token Storage**: Store tokens securely (HttpOnly cookies for web)
- **Token Rotation**: Implement proper refresh token rotation

### 3. User Data Privacy
- **Attribute Mapping**: Only map necessary user attributes
- **Data Retention**: Understand data retention policies of external providers
- **Consent**: Ensure proper user consent for data sharing

### 4. Provider-Specific Security

#### Google
- Enable 2FA on Google account used for OAuth setup
- Regularly rotate client secrets
- Monitor OAuth consent screen usage

#### Facebook
- Enable App Secret Proof for additional security
- Regularly review app permissions
- Monitor app usage in Facebook Analytics

#### Apple
- Securely store private key
- Regularly rotate keys
- Use team-managed certificates

## Troubleshooting

### Common Issues

1. **Invalid Redirect URI**
   - Ensure callback URLs match exactly in both Cognito and external provider
   - Check for trailing slashes and protocol (http vs https)

2. **Attribute Mapping Errors**
   - Verify external provider returns expected attributes
   - Check attribute names match provider documentation

3. **Provider Configuration Issues**
   - Validate client IDs and secrets
   - Ensure provider APIs are enabled
   - Check provider-specific configuration requirements

4. **Token Verification Failures**
   - Verify JWKS URI is accessible
   - Check token expiration times
   - Validate issuer and audience claims

### Debugging Tips

1. **Check CloudWatch Logs**: Cognito logs authentication events
2. **Use Browser Developer Tools**: Inspect OAuth flows and redirects
3. **Test Provider APIs**: Verify external provider credentials work independently
4. **Validate JWT Tokens**: Use jwt.io to decode and inspect tokens

## Cost Considerations

- **Free Tier**: 50,000 MAUs free (applies to all authentication methods)
- **External Provider Costs**: Some providers may charge for API usage
- **Advanced Security**: Additional charges when enabled in enforced mode

## Next Steps

Once you have federated authentication working, you might want to explore:

1. **[Lambda Triggers Example](../lambda-triggers/)** - Add custom logic for federated users
2. **[IAM Role Mappings Example](../iam-role-mappings/)** - Map federated users to AWS IAM roles
3. **Custom Domains** - Use your own domain for the hosted UI

## Cleanup

To destroy the resources:

```bash
terraform destroy
```

**Note**: Remember to also clean up any external provider configurations (OAuth apps, etc.).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
