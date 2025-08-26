# Basic Cognito User Pool Example

This example demonstrates how to create a basic AWS Cognito User Pool with essential features for user authentication.

## What This Example Creates

- A Cognito User Pool with email-based authentication
- A single web client for user authentication
- Basic password policy with security requirements
- Email verification for new users
- Account recovery via email

## Features Demonstrated

- **Email Authentication**: Users can sign up and sign in using their email address
- **Password Policy**: Enforces strong passwords with configurable requirements
- **Email Verification**: Automatic email verification for new user accounts
- **Account Recovery**: Users can recover their accounts via verified email
- **Security Settings**: Basic security configuration with advanced security in audit mode

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Client    │───▶│  Cognito User    │───▶│   Your App      │
│                 │    │      Pool        │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
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

   # Customize password policy
   password_minimum_length = 8
   password_require_symbols = true

   # Security settings
   advanced_security_mode = "AUDIT"
   ```

3. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Options

### Password Policy

You can customize the password requirements:

```hcl
password_minimum_length         = 12
password_require_lowercase      = true
password_require_numbers        = true
password_require_symbols        = true
password_require_uppercase      = true
temporary_password_validity_days = 7
```

### Security Settings

Configure security features:

```hcl
# Advanced security mode
advanced_security_mode = "AUDIT"  # or "ENFORCED" or "OFF"

# Multi-factor authentication
mfa_configuration = "OFF"  # or "OPTIONAL" or "ON"

# Admin-only user creation
allow_admin_create_user_only = false
```

## Testing the User Pool

After deployment, you can test the user pool using the AWS CLI:

1. **Sign up a new user**:
   ```bash
   aws cognito-idp sign-up \
     --client-id <CLIENT_ID> \
     --username user@example.com \
     --password TempPassword123! \
     --user-attributes Name=email,Value=user@example.com
   ```

2. **Confirm the user** (using the verification code from email):
   ```bash
   aws cognito-idp confirm-sign-up \
     --client-id <CLIENT_ID> \
     --username user@example.com \
     --confirmation-code <CODE>
   ```

3. **Authenticate the user**:
   ```bash
   aws cognito-idp initiate-auth \
     --client-id <CLIENT_ID> \
     --auth-flow USER_SRP_AUTH \
     --auth-parameters USERNAME=user@example.com,SRP_A=<SRP_A>
   ```

## Integration with Applications

### Web Applications

Use the Cognito JavaScript SDK:

```javascript
import { CognitoUserPool, CognitoUser, AuthenticationDetails } from 'amazon-cognito-identity-js';

const poolData = {
  UserPoolId: '<USER_POOL_ID>',
  ClientId: '<CLIENT_ID>'
};

const userPool = new CognitoUserPool(poolData);

// Sign up
userPool.signUp(username, password, attributeList, null, callback);

// Sign in
const authenticationDetails = new AuthenticationDetails({
  Username: username,
  Password: password
});

const cognitoUser = new CognitoUser({
  Username: username,
  Pool: userPool
});

cognitoUser.authenticateUser(authenticationDetails, callbacks);
```

### Mobile Applications

Use the AWS Amplify SDK:

```javascript
import { Auth } from 'aws-amplify';

// Configure Amplify
Auth.configure({
  region: '<AWS_REGION>',
  userPoolId: '<USER_POOL_ID>',
  userPoolWebClientId: '<CLIENT_ID>'
});

// Sign up
await Auth.signUp({
  username: 'user@example.com',
  password: 'TempPassword123!',
  attributes: {
    email: 'user@example.com'
  }
});

// Sign in
await Auth.signIn('user@example.com', 'TempPassword123!');
```

## Outputs

This example provides the following outputs:

- `user_pool_id`: The ID of the created user pool
- `user_pool_arn`: The ARN of the user pool
- `user_pool_client_id`: The ID of the web client
- `user_pool_jwks_uri`: The JWKS URI for token verification
- `user_pool_issuer`: The issuer URL for JWT tokens

## Security Considerations

1. **Password Policy**: The default password policy requires 8+ characters with mixed case, numbers, and symbols
2. **Email Verification**: Users must verify their email before they can sign in
3. **Advanced Security**: Enabled in audit mode to monitor suspicious activities
4. **Account Recovery**: Only verified email addresses can be used for account recovery

## Cost Considerations

- **Free Tier**: AWS Cognito provides 50,000 MAUs (Monthly Active Users) free
- **Beyond Free Tier**: $0.0055 per MAU for the first 50,000 MAUs
- **Advanced Security**: Additional charges apply when enabled in enforced mode

## Next Steps

Once you have the basic user pool working, you might want to explore:

1. **[Hosted UI Example](../hosted-ui-app-client/)** - Add a hosted authentication UI
2. **[Federated Identity Provider Example](../federated-identity-provider/)** - Add external Identity providers for login
3. **[Lambda Triggers Example](../lambda-triggers/)** - Add custom authentication logic
4. **[Advanced Security Example](../advanced-security/)** - Add advanced security controls

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
