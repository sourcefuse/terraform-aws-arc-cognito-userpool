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
  default     = "cognito-auth"
}

# ==============================================================================
# OPTIONAL VARIABLES - PASSWORD POLICY
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
# OPTIONAL VARIABLES - USER CREATION
# ==============================================================================

variable "allow_admin_create_user_only" {
  description = "Set to true if only the administrator is allowed to create user profiles"
  type        = bool
  default     = false
}

# ==============================================================================
# OPTIONAL VARIABLES - SECURITY
# ==============================================================================

variable "advanced_security_mode" {
  description = "Mode for advanced security features"
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be one of: OFF, AUDIT, ENFORCED."
  }
}

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "enable_software_token_mfa" {
  description = "Whether to enable software token MFA (TOTP)"
  type        = bool
  default     = false
}

variable "challenge_required_on_new_device" {
  description = "Whether to challenge users on new devices"
  type        = bool
  default     = false
}

variable "device_only_remembered_on_user_prompt" {
  description = "Whether devices are only remembered when user chooses to remember"
  type        = bool
  default     = true
}
