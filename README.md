# AWS Cognito User Pool Terraform Module

[![Pre-commit](https://github.com/your-org/terraform-aws-cognito-user-pool/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/your-org/terraform-aws-cognito-user-pool/actions/workflows/pre-commit.yaml)
[![Terraform Test](https://github.com/your-org/terraform-aws-cognito-user-pool/actions/workflows/terraform-test.yaml/badge.svg)](https://github.com/your-org/terraform-aws-cognito-user-pool/actions/workflows/terraform-test.yaml)

A comprehensive, production-ready Terraform module for creating and managing AWS Cognito User Pools with all associated resources including clients, domains, identity providers, groups, and resource servers.

## Table of Contents

- [Features](#features)
- [Usage](#usage)
- [Examples](#examples)
- [Requirements](#requirements)
- [Providers](#providers)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Security Best Practices](#security-best-practices)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✅ **Complete Cognito User Pool Management**: Create and configure user pools with all available settings
- ✅ **Security Best Practices**: Built-in security configurations following AWS recommendations
- ✅ **Flexible Client Configuration**: Support for multiple app clients with different configurations
- ✅ **Identity Provider Integration**: Support for SAML, OIDC, and social identity providers
- ✅ **Advanced Security Features**: MFA, advanced security mode, adaptive authentication
- ✅ **Lambda Triggers**: Support for all Cognito Lambda triggers
- ✅ **Custom Domains**: Support for custom domains with SSL certificates
- ✅ **User Pool Groups**: Role-based access control with user groups
- ✅ **Resource Servers**: OAuth 2.0 resource server configuration
- ✅ **Conditional Resource Creation**: Create only the resources you need
- ✅ **Comprehensive Validation**: Input validation for all variables
- ✅ **SourceFuse ARC Integration**: Compatible with SourceFuse ARC tags module
- ✅ **Flexible Tagging**: Support for custom tags via tags variable

## Usage

### Basic Usage

```hcl
module "cognito_user_pool" {
  source = "your-org/cognito-user-pool/aws"
  version = "~> 1.0"

  name = "my-user-pool"

  # Enable email verification
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  # Basic password policy
  password_policy = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Create a basic client
  user_pool_clients = [
    {
      name                = "web-client"
      generate_secret     = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
    }
  ]

  tags = {
    Environment = "production"
    Project     = "arc"
  }
}
```

### Advanced Usage with SourceFuse ARC Tags

```hcl
# Using the external sourcefuse/arc-tags/aws module (like the reference module)
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = "prod"
  project     = "cognito-auth"

  extra_tags = {
    Owner = "platform-team"
    Repo  = "github.com/myorg/terraform-aws-cognito-user-pool"
  }
}

module "cognito_user_pool" {
  source = "your-org/cognito-user-pool/aws"
  version = "~> 1.0"

  name = "myorg-prod-user-pool"

  # Advanced security features
  advanced_security_mode = "ENFORCED"
  mfa_configuration      = "OPTIONAL"

  # Custom domain
  create_user_pool_domain = true
  user_pool_domain = {
    domain          = "auth.example.com"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }

  # Identity providers
  create_identity_providers = true
  identity_providers = [
    {
      provider_name = "Google"
      provider_type = "Google"
      provider_details = {
        client_id     = "your-google-client-id"
        client_secret = "your-google-client-secret"
      }
      attribute_mapping = {
        email    = "email"
        username = "sub"
      }
    }
  ]

  # User groups
  create_user_pool_groups = true
  user_pool_groups = [
    {
      name        = "admin"
      description = "Administrator group"
      precedence  = 1
      role_arn    = "arn:aws:iam::123456789012:role/CognitoAdminRole"
    }
  ]

  # Use tags from the arc-tags module
  tags = module.tags.tags
}
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Create a basic app client
  user_pool_clients = [
    {
      name                = "web-client"
      explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
    }
  ]

  tags = {
    Environment = "production"
    Project     = "arc"
  }
}
```

### Advanced Usage with All Features

```hcl
module "cognito_user_pool" {
  source = "./modules/cognito-user-pool"

  name                = "advanced-user-pool"
  deletion_protection = "ACTIVE"
  user_pool_tier      = "PLUS"

  # Authentication configuration
  alias_attributes         = ["email", "phone_number"]
  auto_verified_attributes = ["email"]

  # Advanced security
  advanced_security_mode = "ENFORCED"
  mfa_configuration      = "OPTIONAL"

  # Password policy
  password_policy = {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
    password_history_size            = 5
  }

  # Software token MFA
  software_token_mfa_configuration = {
    enabled = true
  }

  # Email configuration with SES
  email_configuration = {
    email_sending_account = "DEVELOPER"
    from_email_address    = "noreply@example.com"
    source_arn           = "arn:aws:ses:us-east-1:123456789012:identity/example.com"
  }

  # Custom domain
  create_user_pool_domain = true
  user_pool_domain = {
    domain          = "auth.example.com"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }

  # App clients
  user_pool_clients = [
    {
      name                                 = "web-client"
      generate_secret                      = false
      explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = ["email", "openid", "profile"]
      callback_urls                        = ["https://example.com/callback"]
      logout_urls                          = ["https://example.com/logout"]
      supported_identity_providers         = ["COGNITO", "Google"]
    },
    {
      name                = "mobile-client"
      generate_secret     = true
      explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
    }
  ]

  # Identity providers
  create_identity_providers = true
  identity_providers = [
    {
      provider_name = "Google"
      provider_type = "Google"
      provider_details = {
        client_id     = "your-google-client-id"
        client_secret = "your-google-client-secret"
      }
      attribute_mapping = {
        email    = "email"
        username = "sub"
      }
    }
  ]

  # User groups
  create_user_pool_groups = true
  user_pool_groups = [
    {
      name        = "admin"
      description = "Administrator group"
      precedence  = 1
      role_arn    = "arn:aws:iam::123456789012:role/CognitoAdminRole"
    },
    {
      name        = "user"
      description = "Regular user group"
      precedence  = 2
    }
  ]

  # Lambda triggers
  lambda_config = {
    pre_sign_up         = "arn:aws:lambda:us-east-1:123456789012:function:cognito-pre-signup"
    post_confirmation   = "arn:aws:lambda:us-east-1:123456789012:function:cognito-post-confirmation"
    pre_authentication  = "arn:aws:lambda:us-east-1:123456789012:function:cognito-pre-auth"
    post_authentication = "arn:aws:lambda:us-east-1:123456789012:function:cognito-post-auth"
  }

  tags = {
    Environment = "production"
    Project     = "arc"
    ManagedBy   = "terraform"
  }
}
```

## Tagging

This module supports tagging through the `tags` variable and integrates seamlessly with the SourceFuse ARC ecosystem using the `sourcefuse/arc-tags/aws` module.

### Using SourceFuse ARC Tags (Recommended)

```hcl
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = "prod"
  project     = "cognito-auth"

  extra_tags = {
    Owner = "platform-team"
    Repo  = "github.com/myorg/terraform-aws-cognito-user-pool"
  }
}

module "cognito_user_pool" {
  source = "./"

  name = "myorg-prod-user-pool"
  tags = module.tags.tags
}
```

### Direct Tag Assignment

```hcl
module "cognito_user_pool" {
  source = "./"

  name = "my-user-pool"

  tags = {
    Environment = "production"
    Project     = "cognito-auth"
    Owner       = "platform-team"
  }
}
```

## Examples

The `examples/` directory contains several complete examples:

- **[basic-user-pool](./examples/basic-user-pool/)** - Simple user pool with MFA and device tracking options
- **[hosted-ui-app-client](./examples/hosted-ui-app-client/)** - User pool with hosted UI, OAuth, and user groups
- **[advanced-security](./examples/advanced-security/)** - Advanced security features (requires ADVANCED pricing tier)
- **[federated-identity-provider](./examples/federated-identity-provider/)** - Integration with Google/Facebook/SAML/OIDC providers
- **[lambda-triggers](./examples/lambda-triggers/)** - Custom Lambda functions for authentication flows

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_identity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_user_pool_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_group) | resource |
| [aws_cognito_resource_server.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Security Best Practices

This module implements several security best practices:

### 1. Strong Password Policies
- Configurable minimum length (default: 8 characters)
- Requires uppercase, lowercase, numbers, and symbols by default
- Password history to prevent reuse
- Temporary password validity limits

### 2. Multi-Factor Authentication
- Support for SMS and software token MFA
- Configurable MFA enforcement (OFF, OPTIONAL, ON)
- Custom SMS configuration with external ID for security

### 3. Advanced Security Features
- Advanced security mode with risk-based authentication
- Adaptive authentication capabilities
- Custom authentication flow protection

### 4. Account Recovery
- Multiple recovery mechanisms (email, phone, admin-only)
- Prioritized recovery options
- Secure account recovery flows

### 5. Secure Communication
- HTTPS-only endpoints
- Custom domain support with SSL certificates
- Secure token handling and validation

### 6. Access Control
- User pool groups with IAM role mapping
- Resource servers for OAuth 2.0 scopes
- Fine-grained attribute access control

### 7. Monitoring and Logging
- CloudWatch integration for monitoring
- Comprehensive tagging for resource tracking
- Audit trail capabilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Submit a pull request

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

---

## Inputs

<!-- BEGIN_TF_DOCS -->
<!-- This section will be auto-generated by terraform-docs -->
<!-- END_TF_DOCS -->

## Outputs

<!-- BEGIN_TF_DOCS -->
<!-- This section will be auto-generated by terraform-docs -->
<!-- END_TF_DOCS -->
