# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "name" {
  description = "Name of the Cognito User Pool"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 128
    error_message = "User pool name must be between 1 and 128 characters."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - CORE CONFIGURATION
# ==============================================================================

variable "deletion_protection" {
  description = "When active, DeletionProtection prevents accidental deletion of your user pool"
  type        = string
  default     = "INACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be either 'ACTIVE' or 'INACTIVE'."
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

variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool. Valid values: phone_number, email, or preferred_username"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.alias_attributes : contains(["phone_number", "email", "preferred_username"], attr)
    ])
    error_message = "Alias attributes must be one of: phone_number, email, preferred_username."
  }
}

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.username_attributes : contains(["phone_number", "email"], attr)
    ])
    error_message = "Username attributes must be one of: phone_number, email."
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified. Valid values: email, phone_number"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.auto_verified_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Auto verified attributes must be one of: email, phone_number."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - SECURITY CONFIGURATION
# ==============================================================================

variable "password_policy" {
  description = "Configuration for the user pool password policy"
  type = object({
    minimum_length                   = optional(number, 8)
    require_lowercase                = optional(bool, true)
    require_numbers                  = optional(bool, true)
    require_symbols                  = optional(bool, true)
    require_uppercase                = optional(bool, true)
    temporary_password_validity_days = optional(number, 7)
    password_history_size            = optional(number, 0)
  })
  default = {}

  validation {
    condition     = var.password_policy.minimum_length >= 6 && var.password_policy.minimum_length <= 99
    error_message = "Password minimum length must be between 6 and 99 characters."
  }

  validation {
    condition     = var.password_policy.temporary_password_validity_days >= 0 && var.password_policy.temporary_password_validity_days <= 365
    error_message = "Temporary password validity days must be between 0 and 365."
  }

  validation {
    condition     = var.password_policy.password_history_size >= 0 && var.password_policy.password_history_size <= 24
    error_message = "Password history size must be between 0 and 24."
  }
}

variable "advanced_security_mode" {
  description = "Mode for advanced security features"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be one of: OFF, AUDIT, ENFORCED."
  }
}

variable "custom_auth_mode" {
  description = "Mode of threat protection operation in custom authentication"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["AUDIT", "ENFORCED"], var.custom_auth_mode)
    error_message = "Custom auth mode must be one of: AUDIT, ENFORCED."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - ACCOUNT RECOVERY
# ==============================================================================

variable "account_recovery_mechanisms" {
  description = "List of account recovery mechanisms"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  validation {
    condition = alltrue([
      for mechanism in var.account_recovery_mechanisms :
      contains(["verified_email", "verified_phone_number", "admin_only"], mechanism.name)
    ])
    error_message = "Recovery mechanism names must be one of: verified_email, verified_phone_number, admin_only."
  }

  validation {
    condition = alltrue([
      for mechanism in var.account_recovery_mechanisms :
      mechanism.priority >= 1 && mechanism.priority <= 2
    ])
    error_message = "Recovery mechanism priority must be between 1 and 2."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - ADMIN USER CREATION
# ==============================================================================

variable "admin_create_user_config" {
  description = "Configuration for creating a new user profile"
  type = object({
    allow_admin_create_user_only = optional(bool, false)
    invite_message_template = optional(object({
      email_message = optional(string)
      email_subject = optional(string)
      sms_message   = optional(string)
    }), {})
  })
  default = {}
}

# ==============================================================================
# OPTIONAL VARIABLES - DEVICE CONFIGURATION
# ==============================================================================

variable "device_configuration" {
  description = "Configuration for the user pool's device tracking"
  type = object({
    challenge_required_on_new_device      = optional(bool, false)
    device_only_remembered_on_user_prompt = optional(bool, false)
  })
  default = null
}

# ==============================================================================
# OPTIONAL VARIABLES - EMAIL CONFIGURATION
# ==============================================================================

variable "email_configuration" {
  description = "Configuration for email settings"
  type = object({
    configuration_set      = optional(string)
    email_sending_account  = optional(string, "COGNITO_DEFAULT")
    from_email_address     = optional(string)
    reply_to_email_address = optional(string)
    source_arn             = optional(string)
  })
  default = {}

  validation {
    condition     = contains(["COGNITO_DEFAULT", "DEVELOPER"], var.email_configuration.email_sending_account)
    error_message = "Email sending account must be either 'COGNITO_DEFAULT' or 'DEVELOPER'."
  }
}

variable "email_verification_message" {
  description = "String representing the email verification message"
  type        = string
  default     = null
}

variable "email_verification_subject" {
  description = "String representing the email verification subject"
  type        = string
  default     = null
}

variable "verification_message_template" {
  description = "Configuration for verification message templates"
  type = object({
    default_email_option  = optional(string, "CONFIRM_WITH_CODE")
    email_message         = optional(string)
    email_message_by_link = optional(string)
    email_subject         = optional(string)
    email_subject_by_link = optional(string)
    sms_message           = optional(string)
  })
  default = null

  validation {
    condition     = var.verification_message_template == null || contains(["CONFIRM_WITH_CODE", "CONFIRM_WITH_LINK"], var.verification_message_template.default_email_option)
    error_message = "Default email option must be either 'CONFIRM_WITH_CODE' or 'CONFIRM_WITH_LINK'."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - SMS CONFIGURATION
# ==============================================================================

variable "sms_configuration" {
  description = "Configuration for SMS settings"
  type = object({
    external_id    = string
    sns_caller_arn = string
    sns_region     = optional(string)
  })
  default = null
}

variable "sms_authentication_message" {
  description = "String representing the SMS authentication message"
  type        = string
  default     = null
}

variable "sms_verification_message" {
  description = "String representing the SMS verification message"
  type        = string
  default     = null
}

# ==============================================================================
# OPTIONAL VARIABLES - SOFTWARE TOKEN MFA
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



# ==============================================================================
# OPTIONAL VARIABLES - USERNAME CONFIGURATION
# ==============================================================================

variable "username_configuration" {
  description = "Configuration for username settings"
  type = object({
    case_sensitive = optional(bool, false)
  })
  default = {}
}

# ==============================================================================
# OPTIONAL VARIABLES - USER ATTRIBUTE UPDATE SETTINGS
# ==============================================================================

variable "user_attribute_update_settings" {
  description = "Configuration for user attribute update settings"
  type = object({
    attributes_require_verification_before_update = list(string)
  })
  default = null

  validation {
    condition = var.user_attribute_update_settings == null || alltrue([
      for attr in var.user_attribute_update_settings.attributes_require_verification_before_update :
      contains(["email", "phone_number"], attr)
    ])
    error_message = "Attributes requiring verification must be one of: email, phone_number."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - LAMBDA TRIGGERS
# ==============================================================================

variable "lambda_config" {
  description = "Configuration for AWS Lambda triggers associated with the user pool"
  type = object({
    create_auth_challenge          = optional(string)
    custom_message                 = optional(string)
    define_auth_challenge          = optional(string)
    post_authentication            = optional(string)
    post_confirmation              = optional(string)
    pre_authentication             = optional(string)
    pre_sign_up                    = optional(string)
    pre_token_generation           = optional(string)
    user_migration                 = optional(string)
    verify_auth_challenge_response = optional(string)
    kms_key_id                     = optional(string)
    custom_email_sender = optional(object({
      lambda_arn     = string
      lambda_version = string
    }))
    custom_sms_sender = optional(object({
      lambda_arn     = string
      lambda_version = string
    }))
    pre_token_generation_config = optional(object({
      lambda_arn     = string
      lambda_version = string
    }))
  })
  default = null
}

# ==============================================================================
# OPTIONAL VARIABLES - SCHEMA ATTRIBUTES
# ==============================================================================

variable "schema" {
  description = "Configuration for the schema attributes of a user pool"
  type = list(object({
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    name                     = string
    required                 = optional(bool, false)
    number_attribute_constraints = optional(object({
      max_value = optional(string)
      min_value = optional(string)
    }))
    string_attribute_constraints = optional(object({
      max_length = optional(string)
      min_length = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for attr in var.schema : contains(["Boolean", "Number", "String", "DateTime"], attr.attribute_data_type)
    ])
    error_message = "Attribute data type must be one of: Boolean, Number, String, DateTime."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - WEBAUTHN CONFIGURATION
# ==============================================================================

variable "web_authn_configuration" {
  description = "Configuration for web authn (passkey) settings"
  type = object({
    relying_party_id  = optional(string)
    user_verification = optional(string, "preferred")
  })
  default = null

  validation {
    condition     = var.web_authn_configuration == null || contains(["required", "preferred"], var.web_authn_configuration.user_verification)
    error_message = "User verification must be either 'required' or 'preferred'."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - USER POOL CLIENTS
# ==============================================================================

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
    supported_identity_providers                  = optional(list(string), ["COGNITO"])
    write_attributes                              = optional(list(string), [])
    enable_token_revocation                       = optional(bool, true)
    enable_propagate_additional_user_context_data = optional(bool, false)
    auth_session_validity                         = optional(number, 3)
  }))
  default = []
}

# ==============================================================================
# OPTIONAL VARIABLES - USER POOL DOMAIN
# ==============================================================================

variable "user_pool_domain" {
  description = "Configuration for user pool domain"
  type = object({
    domain          = string
    certificate_arn = optional(string)
  })
  default = null
}

# ==============================================================================
# OPTIONAL VARIABLES - IDENTITY PROVIDERS
# ==============================================================================

variable "identity_providers" {
  description = "List of identity providers to create"
  type = list(object({
    provider_name     = string
    provider_type     = string
    attribute_mapping = optional(map(string), {})
    idp_identifiers   = optional(list(string), [])
    provider_details  = map(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for idp in var.identity_providers : contains(["SAML", "Facebook", "Google", "LoginWithAmazon", "SignInWithApple", "OIDC"], idp.provider_type)
    ])
    error_message = "Provider type must be one of: SAML, Facebook, Google, LoginWithAmazon, SignInWithApple, OIDC."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES - USER POOL GROUPS
# ==============================================================================

variable "user_pool_groups" {
  description = "List of user pool groups to create"
  type = list(object({
    name        = string
    description = optional(string)
    precedence  = optional(number)
    role_arn    = optional(string)
  }))
  default = []
}

# ==============================================================================
# OPTIONAL VARIABLES - RESOURCE SERVERS
# ==============================================================================

variable "resource_servers" {
  description = "List of resource servers to create"
  type = list(object({
    identifier = string
    name       = string
    scope = optional(list(object({
      scope_name        = string
      scope_description = string
    })), [])
  }))
  default = []
}

# ==============================================================================
# OPTIONAL VARIABLES - TAGGING
# ==============================================================================

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# OPTIONAL VARIABLES - CONDITIONAL RESOURCE CREATION
# ==============================================================================

variable "create_user_pool_clients" {
  description = "Whether to create user pool clients"
  type        = bool
  default     = true
}

variable "create_user_pool_domain" {
  description = "Whether to create user pool domain"
  type        = bool
  default     = false
}

variable "create_identity_providers" {
  description = "Whether to create identity providers"
  type        = bool
  default     = false
}

variable "create_user_pool_groups" {
  description = "Whether to create user pool groups"
  type        = bool
  default     = false
}

variable "create_resource_servers" {
  description = "Whether to create resource servers"
  type        = bool
  default     = false
}
