# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace for the resources"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cognito-advanced"
}

# ==============================================================================
# THREAT DETECTION CONFIGURATION
# ==============================================================================
variable "user_pool_add_ons" {
  description = <<EOT
Advanced security configuration for Cognito User Pool.
- advanced_security_mode: OFF | AUDIT | ENFORCED
- advanced_security_additional_flows: (optional) block for custom flows
    - custom_auth_mode: e.g. "AUDIT" or "ENFORCED"
EOT

  type = object({
    advanced_security_mode = string
    advanced_security_additional_flows = optional(object({
      custom_auth_mode = string
    }))
  })

  default = {
    advanced_security_mode             = "AUDIT"
    advanced_security_additional_flows = null
  }
}
variable "account_takeover_risk_configuration" {
  type = object({
    notify_configuration = object({
      from       = optional(string)
      reply_to   = optional(string)
      source_arn = string
      block_email = optional(object({
        html_body = string
        text_body = string
        subject   = string
      }))
      mfa_email = optional(object({
        html_body = string
        text_body = string
        subject   = string
      }))
      no_action_email = optional(object({
        html_body = string
        text_body = string
        subject   = string
      }))
    })
    actions = object({
      high_action = object({
        event_action = string
        notify       = bool
      })
      medium_action = object({
        event_action = string
        notify       = bool
      })
      low_action = object({
        event_action = string
        notify       = bool
      })
    })
  })
  default = null
}

variable "compromised_credentials_risk_configuration" {
  type = object({
    event_filter = optional(list(string))
    actions = object({
      event_action = string
    })
  })
  default = null
}

variable "risk_exception_configuration" {
  type = object({
    blocked_ip_range_list = optional(list(string))
    skipped_ip_range_list = optional(list(string))
  })
  default = null
}

# ==============================================================================
# MFA CONFIGURATION
# ==============================================================================

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool. Set to null to omit."
  type        = string
  default     = null

  validation {
    condition     = var.mfa_configuration == null || contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "software_token_mfa_configuration" {
  description = "Configuration for software token Multi-Factor Authentication (MFA) settings. Set to null to omit."
  type = object({
    enabled = bool
  })
  default = null

  validation {
    condition = (
      var.software_token_mfa_configuration == null ||
      !(var.mfa_configuration == "OFF" && var.software_token_mfa_configuration.enabled)
    )
    error_message = "software_token_mfa_configuration.enabled cannot be true when mfa_configuration is OFF."
  }
}

variable "user_pool_tier" {
  description = "The user pool feature plan, or tier"
  type        = string
  default     = "ESSENTIALS"

  validation {
    condition     = contains(["LITE", "ESSENTIALS", "PLUS"], var.user_pool_tier)
    error_message = "User pool tier must be one of: LITE, ESSENTIALS, PLUS."
  }
}

# variable "cognito_log_delivery_config" {
#   description = <<EOT
# Optional configuration for Cognito log delivery.
# If null, no log delivery configuration will be created.
# Optional:
# - prefix : Naming prefix for auto-created resources (default = "example").
# - enable_s3_bucket : Auto-create S3 bucket if s3_configuration={} (default = false).
# - enable_cloudwatch_logs : Auto-create CloudWatch Log Group if cloud_watch_logs_configuration={} (default = false).
# - cloudwatch_retention_in_days : Retention for created CloudWatch Log Group (default = 30).
# - log_configurations : List of log configurations, each with:
#   - event_source (string) : "userNotification" or "userAuthEvents"
#   - log_level (string) : "ERROR" or "INFO"
#   - cloud_watch_logs_configuration (object with optional log_group_arn)
#   - firehose_configuration (object with stream_arn)
#   - s3_configuration (object with optional bucket_arn)
# EOT

#   type = object({
#     prefix                       = optional(string, "example")
#     enable_s3_bucket             = optional(bool, false)
#     enable_cloudwatch_logs       = optional(bool, false)
#     cloudwatch_retention_in_days = optional(number, 30)

#     log_configurations = list(object({
#       event_source = string
#       log_level    = string

#       cloud_watch_logs_configuration = optional(object({
#         log_group_arn = optional(string)
#       }))

#       firehose_configuration = optional(object({
#         stream_arn = string
#       }))

#       s3_configuration = optional(object({
#         bucket_arn = optional(string)
#       }))
#     }))
#   })

#   default = null
# }
variable "cognito_log_delivery_config" {
  type = object({
    event_source         = string # e.g. "userAuthEvents" or "userNotification"
    log_level            = string # "ERROR" or "INFO"
    log_destination_type = string # "cloudwatch", "s3", "firehose"

    # Optional overrides
    log_group_name      = optional(string) # for CW logs
    s3_bucket_name      = optional(string) # for S3
    firehose_stream_arn = optional(string) # for Firehose
  })

  validation {
    condition     = contains(["cloudwatch", "s3", "firehose"], var.cognito_log_delivery_config.log_destination_type)
    error_message = "log_destination_type must be one of: cloudwatch, s3, firehose."
  }

  validation {
    condition     = contains(["ERROR", "INFO"], var.cognito_log_delivery_config.log_level)
    error_message = "log_level must be either ERROR or INFO."
  }
}
