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
  default     = "cognito-hosted-ui"
}

# ==============================================================================
# HOSTED UI CONFIGURATION
# ==============================================================================

variable "hosted_ui_config" {
  description = "Cognito Hosted UI configuration"
  type = object({
    name                                 = string
    domain                               = string
    certificate_arn                      = optional(string)
    callback_urls                        = list(string)
    logout_urls                          = list(string)
    default_redirect_uri                 = optional(string)
    allowed_oauth_flows                  = list(string)
    allowed_oauth_flows_user_pool_client = optional(bool, true)
    allowed_oauth_scopes                 = list(string)
    supported_identity_providers         = list(string)
    generate_secret                      = optional(bool, false)
    css_file                             = optional(string)
    image_file                           = optional(string)
  })
  default = null
}

# ==============================================================================
# PASSWORD POLICY CONFIGURATION
# ==============================================================================

variable "password_minimum_length" {
  description = "Minimum length of the password policy"
  type        = number
  default     = 8

  validation {
    condition     = var.password_minimum_length >= 6 && var.password_minimum_length <= 99
    error_message = "Password minimum length must be between 6 and 99 characters."
  }
}

variable "password_require_lowercase" {
  description = "Whether to require lowercase letters in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether to require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether to require symbols in password"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether to require uppercase letters in password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid"
  type        = number
  default     = 7

  validation {
    condition     = var.temporary_password_validity_days >= 0 && var.temporary_password_validity_days <= 365
    error_message = "Temporary password validity days must be between 0 and 365."
  }
}

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}
