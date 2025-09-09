# Advanced Security Cognito User Pool Example

**IMPORTANT**: This example requires the **ADVANCED pricing tier** in your AWS account.

## Features Demonstrated

- **Advanced Security Mode**: `ENFORCED` - Blocks suspicious activity automatically
- **Enhanced Password Policy**: 12+ characters with complexity requirements
- **Device Tracking**: Remember trusted devices and challenge new ones
- **Shorter Token Validity**: Enhanced security with 30-minute tokens
- **MFA Support**: Optional multi-factor authentication

## Prerequisites

1. **Enable ADVANCED pricing tier** in your AWS Cognito console
2. **Understand the costs** - Advanced features have additional per-MAU charges
3. **Review security policies** with your security team

## Advanced Security Features

### Risk-Based Authentication
- Automatically detects and blocks suspicious sign-in attempts
- Analyzes device, location, and behavioral patterns
- Provides risk scores for authentication attempts

### Compromised Credential Detection
- Checks passwords against known compromised credential databases
- Automatically blocks or challenges users with compromised credentials
- Provides security event logging

### Enhanced Monitoring
- Detailed security event logs in CloudWatch
- Risk assessment metrics
- Authentication attempt analysis

## Usage

```bash
# Initialize
terraform init

# Plan (review the advanced features and costs)
terraform plan

# Apply (only if you have ADVANCED tier enabled)
terraform apply
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.5.0 |

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
| <a name="input_account_takeover_risk_configuration"></a> [account\_takeover\_risk\_configuration](#input\_account\_takeover\_risk\_configuration) | n/a | <pre>object({<br/>    notify_configuration = object({<br/>      from       = optional(string)<br/>      reply_to   = optional(string)<br/>      source_arn = string<br/>      block_email = optional(object({<br/>        html_body = string<br/>        text_body = string<br/>        subject   = string<br/>      }))<br/>      mfa_email = optional(object({<br/>        html_body = string<br/>        text_body = string<br/>        subject   = string<br/>      }))<br/>      no_action_email = optional(object({<br/>        html_body = string<br/>        text_body = string<br/>        subject   = string<br/>      }))<br/>    })<br/>    actions = object({<br/>      high_action = object({<br/>        event_action = string<br/>        notify       = bool<br/>      })<br/>      medium_action = object({<br/>        event_action = string<br/>        notify       = bool<br/>      })<br/>      low_action = object({<br/>        event_action = string<br/>        notify       = bool<br/>      })<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_cognito_log_delivery_config"></a> [cognito\_log\_delivery\_config](#input\_cognito\_log\_delivery\_config) | default = null } | <pre>object({<br/>    event_source         = string # e.g. "userAuthEvents" or "userNotification"<br/>    log_level            = string # "ERROR" or "INFO"<br/>    log_destination_type = string # "cloudwatch", "s3", "firehose"<br/><br/>    # Optional overrides<br/>    log_group_name      = optional(string) # for CW logs<br/>    s3_bucket_name      = optional(string) # for S3<br/>    firehose_stream_arn = optional(string) # for Firehose<br/>  })</pre> | n/a | yes |
| <a name="input_compromised_credentials_risk_configuration"></a> [compromised\_credentials\_risk\_configuration](#input\_compromised\_credentials\_risk\_configuration) | n/a | <pre>object({<br/>    event_filter = optional(list(string))<br/>    actions = object({<br/>      event_action = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-Factor Authentication (MFA) configuration for the User Pool. Set to null to omit. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources | `string` | `"arc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"cognito-advanced"` | no |
| <a name="input_risk_exception_configuration"></a> [risk\_exception\_configuration](#input\_risk\_exception\_configuration) | n/a | <pre>object({<br/>    blocked_ip_range_list = optional(list(string))<br/>    skipped_ip_range_list = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_software_token_mfa_configuration"></a> [software\_token\_mfa\_configuration](#input\_software\_token\_mfa\_configuration) | Configuration for software token Multi-Factor Authentication (MFA) settings. Set to null to omit. | <pre>object({<br/>    enabled = bool<br/>  })</pre> | `null` | no |
| <a name="input_user_pool_add_ons"></a> [user\_pool\_add\_ons](#input\_user\_pool\_add\_ons) | Advanced security configuration for Cognito User Pool.<br/>- advanced\_security\_mode: OFF \| AUDIT \| ENFORCED<br/>- advanced\_security\_additional\_flows: (optional) block for custom flows<br/>    - custom\_auth\_mode: e.g. "AUDIT" or "ENFORCED" | <pre>object({<br/>    advanced_security_mode = string<br/>    advanced_security_additional_flows = optional(object({<br/>      custom_auth_mode = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "advanced_security_additional_flows": null,<br/>  "advanced_security_mode": "AUDIT"<br/>}</pre> | no |
| <a name="input_user_pool_tier"></a> [user\_pool\_tier](#input\_user\_pool\_tier) | The user pool feature plan, or tier | `string` | `"ESSENTIALS"` | no |

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
