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
- **File**: `lambda/pre_sign_up.py`

### 2. Post Confirmation Trigger
- **Purpose**: Execute logic after user confirms account
- **Use Cases**: Welcome emails, user profile creation, external system integration
- **File**: `lambda/post_confirmation.py`

### 3. Pre Authentication Trigger
- **Purpose**: Validate conditions before authentication
- **Use Cases**: Account status checks, time-based access, security validation
- **File**: `lambda/pre_authentication.py`

### 4. Post Authentication Trigger
- **Purpose**: Execute logic after successful authentication
- **Use Cases**: Login logging, activity tracking, notifications
- **File**: `lambda/post_authentication.py`


## Usage

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognito_user_pool"></a> [cognito\_user\_pool](#module\_cognito\_user\_pool) | ../../ | n/a |
| <a name="module_post_confirmation_lambda"></a> [post\_confirmation\_lambda](#module\_post\_confirmation\_lambda) | sourcefuse/arc-lambda-function/aws | 0.0.1 |
| <a name="module_pre_authentication_lambda"></a> [pre\_authentication\_lambda](#module\_pre\_authentication\_lambda) | sourcefuse/arc-lambda-function/aws | 0.0.1 |
| <a name="module_pre_sign_up_lambda"></a> [pre\_sign\_up\_lambda](#module\_pre\_sign\_up\_lambda) | sourcefuse/arc-lambda-function/aws | 0.0.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_enable_post_confirmation_trigger"></a> [enable\_post\_confirmation\_trigger](#input\_enable\_post\_confirmation\_trigger) | Whether to enable post confirmation Lambda trigger | `bool` | `true` | no |
| <a name="input_enable_pre_authentication_trigger"></a> [enable\_pre\_authentication\_trigger](#input\_enable\_pre\_authentication\_trigger) | Whether to enable pre authentication Lambda trigger | `bool` | `false` | no |
| <a name="input_enable_pre_sign_up_trigger"></a> [enable\_pre\_sign\_up\_trigger](#input\_enable\_pre\_sign\_up\_trigger) | Whether to enable pre sign-up Lambda trigger | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources | `string` | `"arc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"cognito-lambda"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled_triggers"></a> [enabled\_triggers](#output\_enabled\_triggers) | List of enabled Lambda triggers |
| <a name="output_post_confirmation_lambda_arn"></a> [post\_confirmation\_lambda\_arn](#output\_post\_confirmation\_lambda\_arn) | ARN of the post confirmation Lambda function |
| <a name="output_pre_authentication_lambda_arn"></a> [pre\_authentication\_lambda\_arn](#output\_pre\_authentication\_lambda\_arn) | ARN of the pre authentication Lambda function |
| <a name="output_pre_sign_up_lambda_arn"></a> [pre\_sign\_up\_lambda\_arn](#output\_pre\_sign\_up\_lambda\_arn) | ARN of the pre sign-up Lambda function |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | The ARN of the Cognito User Pool |
| <a name="output_user_pool_client_id"></a> [user\_pool\_client\_id](#output\_user\_pool\_client\_id) | The ID of the Cognito User Pool Client |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the Cognito User Pool |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | The name of the Cognito User Pool |
<!-- END_TF_DOCS -->
