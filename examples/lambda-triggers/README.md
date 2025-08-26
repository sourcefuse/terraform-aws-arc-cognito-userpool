# Lambda Triggers Example

This example demonstrates how to create a Cognito User Pool with Lambda triggers for custom authentication logic and workflows.

## What This Example Creates

- A Cognito User Pool with email-based authentication
- Lambda functions for various Cognito triggers
- IAM roles and policies for Lambda execution
- Optional DynamoDB table for user migration
- CloudWatch logs for monitoring trigger execution

## Available Lambda Triggers

### 1. Pre Sign-up Trigger
- **Purpose**: Validate user data before sign-up
- **Use Cases**: Email domain validation, user blocking, auto-confirmation
- **File**: `lambda_functions/pre_sign_up.py`

### 2. Post Confirmation Trigger
- **Purpose**: Execute logic after user confirms account
- **Use Cases**: Welcome emails, user profile creation, external system integration
- **File**: `lambda_functions/post_confirmation.py`

### 3. Pre Authentication Trigger
- **Purpose**: Validate conditions before authentication
- **Use Cases**: Account status checks, time-based access, security validation
- **File**: `lambda_functions/pre_authentication.py`

### 4. Post Authentication Trigger
- **Purpose**: Execute logic after successful authentication
- **Use Cases**: Login logging, activity tracking, notifications
- **File**: `lambda_functions/post_authentication.py`

### 5. Custom Message Trigger
- **Purpose**: Customize email and SMS messages
- **Use Cases**: Branded messages, localization, dynamic content
- **File**: `lambda_functions/custom_message.py`

### 6. User Migration Trigger
- **Purpose**: Migrate users from legacy systems
- **Use Cases**: Seamless migration, credential validation, user import
- **File**: `lambda_functions/user_migration.py`

## Quick Start

1. **Copy configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit variables** in `terraform.tfvars`:
   ```hcl
   enable_pre_sign_up_trigger = true
   enable_post_confirmation_trigger = true
   # ... configure other triggers as needed
   ```

3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Test the triggers** by signing up a new user through the AWS CLI or SDK.

## Testing Lambda Triggers

After deployment, test each trigger:

```bash
# Get outputs
terraform output

# Test sign-up (triggers pre_sign_up, custom_message, post_confirmation)
aws cognito-idp sign-up \
  --client-id <CLIENT_ID> \
  --username test@example.com \
  --password TempPassword123! \
  --user-attributes Name=email,Value=test@example.com

# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/arc-dev"
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Next Steps

Once you have Lambda triggers working, explore:
1. **[IAM Role Mappings Example](../iam-role-mappings/)** - Fine-grained access control
2. Customize the Lambda functions for your specific use cases
3. Add monitoring and alerting for trigger failures
