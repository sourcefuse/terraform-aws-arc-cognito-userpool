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

variable "create_hosted_ui_domain" {
  description = "Whether to create a hosted UI domain"
  type        = bool
  default     = true
}

variable "hosted_ui_domain_prefix" {
  description = "Domain prefix for the hosted UI (if null, will use project-environment-auth)"
  type        = string
  default     = null
}

variable "callback_urls" {
  description = "List of allowed callback URLs for the app client"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the app client"
  type        = list(string)
  default     = ["http://localhost:3000/logout"]
}

variable "default_redirect_uri" {
  description = "Default redirect URI for the app client"
  type        = string
  default     = "http://localhost:3000/callback"
}

# ==============================================================================
# OAUTH CONFIGURATION
# ==============================================================================

variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = ["code", "implicit"]

  validation {
    condition = alltrue([
      for flow in var.allowed_oauth_flows : contains(["code", "implicit", "client_credentials"], flow)
    ])
    error_message = "Allowed OAuth flows must be one of: code, implicit, client_credentials."
  }
}

variable "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  type        = list(string)
  default     = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
}

variable "supported_identity_providers" {
  description = "List of supported identity providers"
  type        = list(string)
  default     = ["COGNITO"]
}

# ==============================================================================
# CLIENT CONFIGURATION
# ==============================================================================

variable "generate_client_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = false
}

# variable "explicit_auth_flows" {
#   description = "List of authentication flows"
#   type        = list(string)
#   default = [
#     "ALLOW_USER_SRP_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_PASSWORD_AUTH"
#   ]
# }

variable "read_attributes" {
  description = "List of user pool attributes the app client can read"
  type        = list(string)
  default = [
    "email",
    "email_verified",
    "name",
    "family_name",
    "given_name",
    "preferred_username"
  ]
}

variable "write_attributes" {
  description = "List of user pool attributes the app client can write"
  type        = list(string)
  default = [
    "email",
    "name",
    "family_name",
    "given_name",
    "preferred_username"
  ]
}

# ==============================================================================
# TOKEN CONFIGURATION
# ==============================================================================

variable "access_token_validity" {
  description = "Time limit, in minutes, after which the access token is no longer valid"
  type        = number
  default     = 60

  validation {
    condition     = var.access_token_validity >= 5 && var.access_token_validity <= 1440
    error_message = "Access token validity must be between 5 minutes and 1 day (1440 minutes)."
  }
}

variable "id_token_validity" {
  description = "Time limit, in minutes, after which the ID token is no longer valid"
  type        = number
  default     = 60

  validation {
    condition     = var.id_token_validity >= 5 && var.id_token_validity <= 1440
    error_message = "ID token validity must be between 5 minutes and 1 day (1440 minutes)."
  }
}

variable "refresh_token_validity" {
  description = "Time limit, in days, after which the refresh token is no longer valid"
  type        = number
  default     = 30

  validation {
    condition     = var.refresh_token_validity >= 1 && var.refresh_token_validity <= 3650
    error_message = "Refresh token validity must be between 1 and 3650 days."
  }
}

# ==============================================================================
# EMAIL CONFIGURATION
# ==============================================================================

# variable "email_verification_method" {
#   description = "Method for email verification"
#   type        = string
#   default     = "CONFIRM_WITH_LINK"

#   validation {
#     condition     = contains(["CONFIRM_WITH_CODE", "CONFIRM_WITH_LINK"], var.email_verification_method)
#     error_message = "Email verification method must be either 'CONFIRM_WITH_CODE' or 'CONFIRM_WITH_LINK'."
#   }
# }

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

variable "create_user_groups" {
  description = "Whether to create user groups"
  type        = bool
  default     = true
}

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

variable "advanced_security_mode" {
  description = "Mode for advanced security features"
  type        = string
  default     = "AUDIT"

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
