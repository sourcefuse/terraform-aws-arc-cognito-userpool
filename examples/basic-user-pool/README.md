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

## Usage

1. **Copy the example configuration**:
   ```bash
   vi terraform.tfvars
   ```

2. **Edit the variables** in `terraform.tfvars`:
   ```hcl
   aws_region   = "us-east-1"
   project_name = "arc"
   environment  = "dev"

   # Customize password policy
   password_minimum_length = 8
   password_require_symbols = true
   ```

3. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognito_user_pool"></a> [cognito\_user\_pool](#module\_cognito\_user\_pool) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_admin_create_user_only"></a> [allow\_admin\_create\_user\_only](#input\_allow\_admin\_create\_user\_only) | Set to true if only the administrator is allowed to create user profiles | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_challenge_required_on_new_device"></a> [challenge\_required\_on\_new\_device](#input\_challenge\_required\_on\_new\_device) | Whether to challenge users on new devices | `bool` | `false` | no |
| <a name="input_create_user_pool_groups"></a> [create\_user\_pool\_groups](#input\_create\_user\_pool\_groups) | Whether to create user pool groups | `bool` | `false` | no |
| <a name="input_create_user_pool_users"></a> [create\_user\_pool\_users](#input\_create\_user\_pool\_users) | Whether to create user pool users | `bool` | `false` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | When active, DeletionProtection prevents accidental deletion of your user pool | `string` | `"INACTIVE"` | no |
| <a name="input_device_only_remembered_on_user_prompt"></a> [device\_only\_remembered\_on\_user\_prompt](#input\_device\_only\_remembered\_on\_user\_prompt) | Whether devices are only remembered when user chooses to remember | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-Factor Authentication (MFA) configuration | `string` | `"OFF"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources | `string` | `"arc"` | no |
| <a name="input_password_minimum_length"></a> [password\_minimum\_length](#input\_password\_minimum\_length) | Minimum length of the password policy | `number` | `8` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether to require lowercase letters in password | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether to require numbers in password | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether to require symbols in password | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether to require uppercase letters in password | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"cognito-auth"` | no |
| <a name="input_software_token_mfa_configuration"></a> [software\_token\_mfa\_configuration](#input\_software\_token\_mfa\_configuration) | Configuration for software token Multi-Factor Authentication (MFA) settings. Set to null to omit. | <pre>object({<br/>    enabled = bool<br/>  })</pre> | `null` | no |
| <a name="input_temporary_password_validity_days"></a> [temporary\_password\_validity\_days](#input\_temporary\_password\_validity\_days) | Number of days a temporary password is valid | `number` | `7` | no |
| <a name="input_user_group_memberships"></a> [user\_group\_memberships](#input\_user\_group\_memberships) | List of user-to-group memberships | <pre>list(object({<br/>    user  = string<br/>    group = string<br/>  }))</pre> | `[]` | no |
| <a name="input_user_pool_clients"></a> [user\_pool\_clients](#input\_user\_pool\_clients) | List of user pool clients to create | <pre>list(object({<br/>    name                   = string<br/>    access_token_validity  = optional(number, 60)<br/>    id_token_validity      = optional(number, 60)<br/>    refresh_token_validity = optional(number, 30)<br/>    token_validity_units = optional(object({<br/>      access_token  = optional(string, "minutes")<br/>      id_token      = optional(string, "minutes")<br/>      refresh_token = optional(string, "days")<br/>    }), {})<br/>    allowed_oauth_flows                           = optional(list(string), [])<br/>    allowed_oauth_flows_user_pool_client          = optional(bool, false)<br/>    allowed_oauth_scopes                          = optional(list(string), [])<br/>    callback_urls                                 = optional(list(string), [])<br/>    default_redirect_uri                          = optional(string)<br/>    explicit_auth_flows                           = optional(list(string), ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"])<br/>    generate_secret                               = optional(bool, false)<br/>    logout_urls                                   = optional(list(string), [])<br/>    prevent_user_existence_errors                 = optional(string, "ENABLED")<br/>    read_attributes                               = optional(list(string), [])<br/>    supported_identity_providers                  = optional(list(string), ["GOOGLE"])<br/>    write_attributes                              = optional(list(string), [])<br/>    enable_token_revocation                       = optional(bool, true)<br/>    enable_propagate_additional_user_context_data = optional(bool, false)<br/>    auth_session_validity                         = optional(number, 3)<br/>  }))</pre> | `[]` | no |
| <a name="input_user_pool_groups"></a> [user\_pool\_groups](#input\_user\_pool\_groups) | List of Cognito groups to create | <pre>list(object({<br/>    name        = string<br/>    description = optional(string, null)<br/>    precedence  = optional(number, null)<br/>    role_arn    = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_user_pool_tier"></a> [user\_pool\_tier](#input\_user\_pool\_tier) | The user pool feature plan, or tier | `string` | `"ESSENTIALS"` | no |
| <a name="input_user_pool_users"></a> [user\_pool\_users](#input\_user\_pool\_users) | List of Cognito users to create | <pre>list(object({<br/>    username = string<br/>    email    = string<br/>    password = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_summary"></a> [summary](#output\_summary) | Summary of the created Cognito User Pool |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | The ARN of the Cognito User Pool |
| <a name="output_user_pool_client_id"></a> [user\_pool\_client\_id](#output\_user\_pool\_client\_id) | The ID of the Cognito User Pool Client |
| <a name="output_user_pool_client_name"></a> [user\_pool\_client\_name](#output\_user\_pool\_client\_name) | The name of the Cognito User Pool Client |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | The endpoint name of the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the Cognito User Pool |
| <a name="output_user_pool_issuer"></a> [user\_pool\_issuer](#output\_user\_pool\_issuer) | The issuer URL for the user pool |
| <a name="output_user_pool_jwks_uri"></a> [user\_pool\_jwks\_uri](#output\_user\_pool\_jwks\_uri) | The JSON Web Key Set (JWKS) URI for the user pool |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | The name of the Cognito User Pool |
<!-- END_TF_DOCS -->
