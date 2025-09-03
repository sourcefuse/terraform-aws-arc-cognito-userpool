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

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "OFF"
}
variable "software_token_mfa_configuration" {
  description = "Configuration for software token Multi-Factor Authentication (MFA) settings. Set to null to omit."
  type = object({
    enabled = bool
  })
  default = null
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
variable "user_pool_groups" {
  description = "List of Cognito groups to create"
  type = list(object({
    name        = string
    description = optional(string, null)
    precedence  = optional(number, null)
    role_arn    = optional(string, null)
  }))
  default = []
}

variable "user_pool_users" {
  description = "List of Cognito users to create"
  type = list(object({
    username = string
    email    = string
    password = string
  }))
  default = []
}

variable "user_group_memberships" {
  description = "List of user-to-group memberships"
  type = list(object({
    user  = string
    group = string
  }))
  default = []
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

variable "deletion_protection" {
  description = "When active, DeletionProtection prevents accidental deletion of your user pool"
  type        = string
  default     = "INACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be either 'ACTIVE' or 'INACTIVE'."
  }
}

variable "create_user_pool_groups" {
  description = "Whether to create user pool groups"
  type        = bool
  default     = false
}
variable "create_user_pool_users" {
  description = "Whether to create user pool users"
  type        = bool
  default     = false
}
variable "user_pool_clients" {
  description = "List of user pool clients to create"
  type = list(object({
    name                   = string
    access_token_validity  = optional(number, 60)
    id_token_validity      = optional(number, 60)
    refresh_token_validity = optional(number, 30)
    token_validity_units = optional(object({
      access_token  = optional(string, "minutes")
      id_token      = optional(string, "minutes")
      refresh_token = optional(string, "days")
    }), {})
    allowed_oauth_flows                           = optional(list(string), [])
    allowed_oauth_flows_user_pool_client          = optional(bool, false)
    allowed_oauth_scopes                          = optional(list(string), [])
    callback_urls                                 = optional(list(string), [])
    default_redirect_uri                          = optional(string)
    explicit_auth_flows                           = optional(list(string), ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"])
    generate_secret                               = optional(bool, false)
    logout_urls                                   = optional(list(string), [])
    prevent_user_existence_errors                 = optional(string, "ENABLED")
    read_attributes                               = optional(list(string), [])
    supported_identity_providers                  = optional(list(string), ["GOOGLE"])
    write_attributes                              = optional(list(string), [])
    enable_token_revocation                       = optional(bool, true)
    enable_propagate_additional_user_context_data = optional(bool, false)
    auth_session_validity                         = optional(number, 3)
  }))
  default = []
}
