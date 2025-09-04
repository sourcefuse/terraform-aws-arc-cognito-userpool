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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="input_allowed_oauth_flows"></a> [allowed\_oauth\_flows](#input\_allowed\_oauth\_flows) | List of allowed OAuth flows | `list(string)` | <pre>[<br/>  "code",<br/>  "implicit"<br/>]</pre> | no |
| <a name="input_allowed_oauth_scopes"></a> [allowed\_oauth\_scopes](#input\_allowed\_oauth\_scopes) | List of allowed OAuth scopes | `list(string)` | <pre>[<br/>  "email",<br/>  "openid",<br/>  "profile",<br/>  "aws.cognito.signin.user.admin"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | List of allowed callback URLs for the app client | `list(string)` | <pre>[<br/>  "http://localhost:3000/callback"<br/>]</pre> | no |
| <a name="input_default_redirect_uri"></a> [default\_redirect\_uri](#input\_default\_redirect\_uri) | Default redirect URI for the app client | `string` | `"http://localhost:3000/callback"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_generate_client_secret"></a> [generate\_client\_secret](#input\_generate\_client\_secret) | Whether to generate a client secret | `bool` | `false` | no |
| <a name="input_hosted_ui_config"></a> [hosted\_ui\_config](#input\_hosted\_ui\_config) | Cognito Hosted UI configuration | <pre>object({<br/>    name                                 = string<br/>    domain                               = string<br/>    certificate_arn                      = optional(string)<br/>    callback_urls                        = list(string)<br/>    logout_urls                          = list(string)<br/>    default_redirect_uri                 = optional(string)<br/>    allowed_oauth_flows                  = list(string)<br/>    allowed_oauth_flows_user_pool_client = optional(bool, true)<br/>    allowed_oauth_scopes                 = list(string)<br/>    supported_identity_providers         = list(string)<br/>    generate_secret                      = optional(bool, false)<br/>    css_file                             = optional(string)<br/>    image_file                           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | List of allowed logout URLs for the app client | `list(string)` | <pre>[<br/>  "http://localhost:3000/logout"<br/>]</pre> | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-Factor Authentication (MFA) configuration | `string` | `"OFF"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources | `string` | `"arc"` | no |
| <a name="input_password_minimum_length"></a> [password\_minimum\_length](#input\_password\_minimum\_length) | Minimum length of the password policy | `number` | `8` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether to require lowercase letters in password | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether to require numbers in password | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether to require symbols in password | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether to require uppercase letters in password | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"cognito-hosted-ui"` | no |
| <a name="input_temporary_password_validity_days"></a> [temporary\_password\_validity\_days](#input\_temporary\_password\_validity\_days) | Number of days a temporary password is valid | `number` | `7` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosted_ui_domain"></a> [hosted\_ui\_domain](#output\_hosted\_ui\_domain) | The domain name for the hosted UI |
| <a name="output_hosted_ui_url"></a> [hosted\_ui\_url](#output\_hosted\_ui\_url) | The URL of the hosted UI |
| <a name="output_login_url"></a> [login\_url](#output\_login\_url) | The login URL for the hosted UI |
| <a name="output_logout_url"></a> [logout\_url](#output\_logout\_url) | The logout URL for the hosted UI |
| <a name="output_oauth_configuration"></a> [oauth\_configuration](#output\_oauth\_configuration) | OAuth configuration details for client applications |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary of the created Cognito User Pool with Hosted UI |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | The ARN of the Cognito User Pool |
| <a name="output_user_pool_client_id"></a> [user\_pool\_client\_id](#output\_user\_pool\_client\_id) | The ID of the Cognito User Pool Client |
| <a name="output_user_pool_client_name"></a> [user\_pool\_client\_name](#output\_user\_pool\_client\_name) | The name of the Cognito User Pool Client |
| <a name="output_user_pool_client_secret"></a> [user\_pool\_client\_secret](#output\_user\_pool\_client\_secret) | The client secret of the Cognito User Pool Client (if generated) |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | The endpoint name of the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the Cognito User Pool |
| <a name="output_user_pool_issuer"></a> [user\_pool\_issuer](#output\_user\_pool\_issuer) | The issuer URL for the user pool |
| <a name="output_user_pool_jwks_uri"></a> [user\_pool\_jwks\_uri](#output\_user\_pool\_jwks\_uri) | The JSON Web Key Set (JWKS) URI for the user pool |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | The name of the Cognito User Pool |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
