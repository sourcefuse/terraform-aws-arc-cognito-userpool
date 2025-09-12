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

1. **Update the example configuration**:
   ```bash
   terraform.tfvars
   ```

2. **Edit the variables** in `terraform.tfvars`:
   ```hcl
   # Enable Google provider
   identity_providers_config = {
      google = {
        enabled       = true
        client_id     = "<google-client-id>"
        client_secret = "<google-client-secret>"
        scopes        = ["openid", "email", "profile"]
        attribute_mapping = {
          email              = "email"
          family_name        = "family_name"
          given_name         = "given_name"
          name               = "name"
          picture            = "picture"
          preferred_username = "sub"
          username           = "sub"
        }
      }
    }
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognito_user_pool"></a> [cognito\_user\_pool](#module\_cognito\_user\_pool) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_token_validity"></a> [access\_token\_validity](#input\_access\_token\_validity) | Time limit, in minutes, after which the access token is no longer valid | `number` | `60` | no |
| <a name="input_allowed_oauth_flows"></a> [allowed\_oauth\_flows](#input\_allowed\_oauth\_flows) | List of allowed OAuth flows | `list(string)` | <pre>[<br/>  "code",<br/>  "implicit"<br/>]</pre> | no |
| <a name="input_allowed_oauth_scopes"></a> [allowed\_oauth\_scopes](#input\_allowed\_oauth\_scopes) | List of allowed OAuth scopes | `list(string)` | <pre>[<br/>  "email",<br/>  "openid",<br/>  "profile",<br/>  "aws.cognito.signin.user.admin"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | List of allowed callback URLs for the app client | `list(string)` | <pre>[<br/>  "http://localhost:3000/callback"<br/>]</pre> | no |
| <a name="input_create_hosted_ui_domain"></a> [create\_hosted\_ui\_domain](#input\_create\_hosted\_ui\_domain) | Whether to create a hosted UI domain | `bool` | `true` | no |
| <a name="input_default_redirect_uri"></a> [default\_redirect\_uri](#input\_default\_redirect\_uri) | Default redirect URI for the app client | `string` | `"http://localhost:3000/callback"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_explicit_auth_flows"></a> [explicit\_auth\_flows](#input\_explicit\_auth\_flows) | List of authentication flows | `list(string)` | <pre>[<br/>  "ALLOW_USER_SRP_AUTH",<br/>  "ALLOW_REFRESH_TOKEN_AUTH",<br/>  "ALLOW_USER_PASSWORD_AUTH"<br/>]</pre> | no |
| <a name="input_generate_client_secret"></a> [generate\_client\_secret](#input\_generate\_client\_secret) | Whether to generate a client secret | `bool` | `false` | no |
| <a name="input_hosted_ui_domain_prefix"></a> [hosted\_ui\_domain\_prefix](#input\_hosted\_ui\_domain\_prefix) | Domain prefix for the hosted UI (if null, will use project-environment-auth) | `string` | `null` | no |
| <a name="input_id_token_validity"></a> [id\_token\_validity](#input\_id\_token\_validity) | Time limit, in minutes, after which the ID token is no longer valid | `number` | `60` | no |
| <a name="input_identity_providers_config"></a> [identity\_providers\_config](#input\_identity\_providers\_config) | Configuration for optional identity providers | <pre>object({<br/>    google = optional(object({<br/>      enabled           = optional(bool, false)<br/>      client_id         = optional(string)<br/>      client_secret     = optional(string)<br/>      scopes            = optional(list(string), ["openid", "email", "profile"])<br/>      attribute_mapping = optional(map(string), {})<br/>    }), {})<br/><br/>    facebook = optional(object({<br/>      enabled           = optional(bool, false)<br/>      app_id            = optional(string)<br/>      app_secret        = optional(string)<br/>      scopes            = optional(list(string), ["public_profile", "email"])<br/>      attribute_mapping = optional(map(string), {})<br/>    }), {})<br/><br/>    apple = optional(object({<br/>      enabled           = optional(bool, false)<br/>      services_id       = optional(string)<br/>      team_id           = optional(string)<br/>      key_id            = optional(string)<br/>      private_key       = optional(string)<br/>      scopes            = optional(list(string), ["name", "email"])<br/>      attribute_mapping = optional(map(string), {})<br/>    }), {})<br/><br/>    amazon = optional(object({<br/>      enabled           = optional(bool, false)<br/>      client_id         = optional(string)<br/>      client_secret     = optional(string)<br/>      scopes            = optional(list(string), ["profile"])<br/>      attribute_mapping = optional(map(string), {})<br/>    }), {})<br/><br/>    saml = optional(object({<br/>      enabled           = optional(bool, false)<br/>      provider_name     = optional(string)<br/>      metadata_url      = optional(string)<br/>      attribute_mapping = optional(map(string), {})<br/>      idp_identifiers   = optional(list(string), [])<br/>    }), {})<br/><br/>    oidc = optional(object({<br/>      enabled           = optional(bool, false)<br/>      provider_name     = optional(string)<br/>      client_id         = optional(string)<br/>      client_secret     = optional(string)<br/>      issuer_url        = optional(string)<br/>      scopes            = optional(list(string), ["openid", "email", "profile"])<br/>      attribute_mapping = optional(map(string), {})<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | List of allowed logout URLs for the app client | `list(string)` | <pre>[<br/>  "http://localhost:3000/logout"<br/>]</pre> | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-Factor Authentication (MFA) configuration | `string` | `"OPTIONAL"` | no |
| <a name="input_password_minimum_length"></a> [password\_minimum\_length](#input\_password\_minimum\_length) | Minimum length of the password policy | `number` | `8` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether to require lowercase letters in password | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether to require numbers in password | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether to require symbols in password | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether to require uppercase letters in password | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"arc"` | no |
| <a name="input_read_attributes"></a> [read\_attributes](#input\_read\_attributes) | List of user pool attributes the app client can read | `list(string)` | <pre>[<br/>  "email",<br/>  "email_verified",<br/>  "name",<br/>  "family_name",<br/>  "given_name",<br/>  "preferred_username",<br/>  "picture"<br/>]</pre> | no |
| <a name="input_refresh_token_validity"></a> [refresh\_token\_validity](#input\_refresh\_token\_validity) | Time limit, in days, after which the refresh token is no longer valid | `number` | `30` | no |
| <a name="input_temporary_password_validity_days"></a> [temporary\_password\_validity\_days](#input\_temporary\_password\_validity\_days) | Number of days a temporary password is valid | `number` | `7` | no |
| <a name="input_user_pool_tier"></a> [user\_pool\_tier](#input\_user\_pool\_tier) | The user pool feature plan, or tier | `string` | `"PLUS"` | no |
| <a name="input_write_attributes"></a> [write\_attributes](#input\_write\_attributes) | List of user pool attributes the app client can write | `list(string)` | <pre>[<br/>  "email",<br/>  "name",<br/>  "family_name",<br/>  "given_name",<br/>  "preferred_username",<br/>  "picture"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | The ARN of the Cognito User Pool |
| <a name="output_user_pool_client_id"></a> [user\_pool\_client\_id](#output\_user\_pool\_client\_id) | The ID of the Cognito User Pool Client |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | The endpoint name of the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the Cognito User Pool |
| <a name="output_user_pool_issuer"></a> [user\_pool\_issuer](#output\_user\_pool\_issuer) | The issuer URL for JWT tokens |
| <a name="output_user_pool_jwks_uri"></a> [user\_pool\_jwks\_uri](#output\_user\_pool\_jwks\_uri) | The JWKS URI for JWT token validation |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | The name of the Cognito User Pool |
<!-- END_TF_DOCS -->
