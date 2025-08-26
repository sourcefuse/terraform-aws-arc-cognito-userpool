# Hosted UI App Client Example

This example demonstrates how to create a Cognito User Pool with a hosted authentication UI and OAuth 2.0 configuration for web applications.

## What This Example Creates

- A Cognito User Pool with email-based authentication
- A hosted UI domain for authentication flows
- An app client configured for OAuth 2.0 flows
- Support for authorization code and implicit grant flows
- Optional MFA with software tokens (TOTP)
- Customizable token validity periods

## Features Demonstrated

- **Hosted Authentication UI**: Pre-built sign-up, sign-in, and password reset pages
- **OAuth 2.0 Flows**: Support for authorization code and implicit grant flows
- **Customizable Scopes**: Configure which user attributes and permissions to grant
- **Token Management**: Configurable access, ID, and refresh token validity
- **Multi-Factor Authentication**: Optional TOTP-based MFA
- **Email Verification**: Link-based or code-based email verification

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
                       ┌──────────────────┐
                       │  Email Service   │
                       │  (Verification)  │
                       └──────────────────┘
```

## Usage

1. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit the variables** in `terraform.tfvars`:
   ```hcl
   aws_region   = "us-east-1"
   project_name = "arc"
   environment  = "dev"

   # Update callback URLs for your application
   callback_urls = [
     "http://localhost:3000/callback",
     "https://myapp.example.com/callback"
   ]

   logout_urls = [
     "http://localhost:3000/logout",
     "https://myapp.example.com/logout"
   ]
   ```

3. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Note the outputs** - you'll need these for your application:
   ```bash
   terraform output
   ```

## Configuration Options

### OAuth 2.0 Flows

Configure which OAuth flows your application supports:

```hcl
# For single-page applications (SPA)
allowed_oauth_flows = ["implicit"]

# For server-side applications
allowed_oauth_flows = ["code"]

# For both
allowed_oauth_flows = ["code", "implicit"]
```

### OAuth Scopes

Control what information and permissions to grant:

```hcl
allowed_oauth_scopes = [
  "email",                           # User's email address
  "openid",                         # OpenID Connect
  "profile",                        # User profile information
  "aws.cognito.signin.user.admin"   # Full user management
]
```

### Token Validity

Configure how long tokens remain valid:

```hcl
access_token_validity  = 60   # 1 hour (5-1440 minutes)
id_token_validity      = 60   # 1 hour (5-1440 minutes)
refresh_token_validity = 30   # 30 days (1-3650 days)
```

### Client Secret

For server-side applications that can securely store secrets:

```hcl
generate_client_secret = true
```

For single-page applications or mobile apps:

```hcl
generate_client_secret = false
```

## Testing the Hosted UI

After deployment, you can test the hosted UI:

1. **Get the hosted UI URL** from the outputs:
   ```bash
   terraform output hosted_ui_url
   ```

2. **Visit the login URL** (also provided in outputs):
   ```
   https://arc-dev-auth.auth.us-east-1.amazoncognito.com/login?client_id=<CLIENT_ID>&response_type=code&scope=email+openid+profile&redirect_uri=http://localhost:3000/callback
   ```

3. **Test the authentication flow**:
   - Sign up with a new user
   - Verify email address
   - Sign in with credentials
   - Test password reset
   - Test MFA (if enabled)

## Integration with Applications

### Single-Page Applications (React/Vue/Angular)

Use the AWS Amplify library:

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

// Use hosted UI for authentication
Auth.federatedSignIn();

// Handle callback
Auth.currentAuthenticatedUser()
  .then(user => console.log(user))
  .catch(err => console.log(err));
```

### Server-Side Applications (Node.js/Python/Java)

Use the authorization code flow:

```javascript
// Node.js example with express
const express = require('express');
const axios = require('axios');
const app = express();

// Redirect to Cognito hosted UI
app.get('/login', (req, res) => {
  const authUrl = `https://<HOSTED_UI_DOMAIN>/login?client_id=<CLIENT_ID>&response_type=code&scope=email+openid+profile&redirect_uri=http://localhost:3000/callback`;
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
      client_secret: '<CLIENT_SECRET>', // Only if using client secret
      code: code,
      redirect_uri: 'http://localhost:3000/callback'
    });

    const { access_token, id_token, refresh_token } = tokenResponse.data;

    // Store tokens securely and redirect user
    res.redirect('/dashboard');
  } catch (error) {
    console.error('Token exchange failed:', error);
    res.redirect('/login');
  }
});
```

### Mobile Applications

Use AWS Amplify or AWS SDK:

```swift
// iOS Swift example
import Amplify
import AWSCognitoAuthPlugin

// Configure Amplify
let authPlugin = AWSCognitoAuthPlugin()
try Amplify.add(plugin: authPlugin)

let amplifyConfig = """
{
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "<IDENTITY_POOL_ID>",
                            "Region": "<AWS_REGION>"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "<USER_POOL_ID>",
                        "AppClientId": "<CLIENT_ID>",
                        "Region": "<AWS_REGION>"
                    }
                },
                "Auth": {
                    "Default": {
                        "OAuth": {
                            "WebDomain": "<HOSTED_UI_DOMAIN>",
                            "AppClientId": "<CLIENT_ID>",
                            "SignInRedirectURI": "myapp://callback",
                            "SignOutRedirectURI": "myapp://logout",
                            "Scopes": ["email", "openid", "profile"]
                        }
                    }
                }
            }
        }
    }
}
"""

try Amplify.configure(amplifyConfig)

// Use hosted UI
Amplify.Auth.signInWithWebUI(presentationAnchor: self.view.window!) { result in
    switch result {
    case .success:
        print("Sign in succeeded")
    case .failure(let error):
        print("Sign in failed \(error)")
    }
}
```

## Customizing the Hosted UI

While this example uses the default hosted UI, you can customize it by:

1. **Adding custom CSS** (requires custom domain)
2. **Configuring custom logos and branding**
3. **Adding custom JavaScript for enhanced functionality**

For advanced customization, consider using a custom domain:

```hcl
user_pool_domain = {
  domain          = "auth.myapp.com"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
}
```

## Security Considerations

1. **HTTPS Only**: Always use HTTPS for callback and logout URLs in production
2. **Client Secret**: Only use client secrets for server-side applications
3. **Token Storage**: Store tokens securely (HttpOnly cookies for web, Keychain for mobile)
4. **PKCE**: Consider using PKCE for additional security in public clients
5. **Scope Limitation**: Only request the minimum required scopes
6. **Token Rotation**: Implement proper refresh token rotation

## Troubleshooting

### Common Issues

1. **Invalid Redirect URI**: Ensure callback URLs match exactly (including trailing slashes)
2. **CORS Issues**: Configure CORS properly for single-page applications
3. **Token Validation**: Verify JWT tokens using the JWKS endpoint
4. **MFA Setup**: Users need to set up MFA before it can be enforced

### Debugging Tips

1. **Check CloudWatch Logs**: Cognito logs authentication events
2. **Use Browser Developer Tools**: Inspect network requests and responses
3. **Validate JWT Tokens**: Use jwt.io to decode and verify tokens
4. **Test with Postman**: Test OAuth flows manually

## Cost Considerations

- **Free Tier**: 50,000 MAUs (Monthly Active Users) free
- **Hosted UI**: No additional cost for using hosted UI
- **Advanced Security**: Additional charges when enabled in enforced mode
- **Custom Domain**: Additional charges for custom SSL certificates

## Next Steps

Once you have the hosted UI working, you might want to explore:

1. **[Federated Identity Provider Example](../federated-identity-provider/)** - Add Google/Facebook login
2. **[Lambda Triggers Example](../lambda-triggers/)** - Add custom authentication logic
3. **[IAM Role Mappings Example](../iam-role-mappings/)** - Fine-grained access control

## Cleanup

To destroy the resources:

```bash
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
