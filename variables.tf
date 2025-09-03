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
#  VARIABLES - CORE CONFIGURATION
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
#  VARIABLES - SECURITY CONFIGURATION
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
  default = null
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
#  VARIABLES - ACCOUNT RECOVERY
# ==============================================================================

variable "account_recovery_mechanisms" {
  description = "List of account recovery mechanisms"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email",
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
#  VARIABLES - ADMIN USER CREATION
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
#  VARIABLES - DEVICE CONFIGURATION
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
#  VARIABLES - EMAIL CONFIGURATION
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
#  VARIABLES - SMS CONFIGURATION
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
# VARIABLES - SOFTWARE TOKEN MFA
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
    supported_identity_providers                  = optional(list(string), ["GOOGLE"])
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
variable "identity_providers_config" {
  description = "Configuration for optional identity providers"
  type = object({
    google = optional(object({
      enabled           = optional(bool, false)
      client_id         = optional(string)
      client_secret     = optional(string)
      scopes            = optional(list(string), ["openid", "email", "profile"])
      attribute_mapping = optional(map(string), {})
    }), {})

    facebook = optional(object({
      enabled           = optional(bool, false)
      app_id            = optional(string)
      app_secret        = optional(string)
      scopes            = optional(list(string), ["public_profile", "email"])
      attribute_mapping = optional(map(string), {})
    }), {})

    apple = optional(object({
      enabled           = optional(bool, false)
      services_id       = optional(string)
      team_id           = optional(string)
      key_id            = optional(string)
      private_key       = optional(string)
      scopes            = optional(list(string), ["name", "email"])
      attribute_mapping = optional(map(string), {})
    }), {})

    amazon = optional(object({
      enabled           = optional(bool, false)
      client_id         = optional(string)
      client_secret     = optional(string)
      scopes            = optional(list(string), ["profile"])
      attribute_mapping = optional(map(string), {})
    }), {})

    saml = optional(object({
      enabled           = optional(bool, false)
      provider_name     = optional(string)
      metadata_url      = optional(string)
      attribute_mapping = optional(map(string), {})
      idp_identifiers   = optional(list(string), [])
    }), {})

    oidc = optional(object({
      enabled           = optional(bool, false)
      provider_name     = optional(string)
      client_id         = optional(string)
      client_secret     = optional(string)
      issuer_url        = optional(string)
      scopes            = optional(list(string), ["openid", "email", "profile"])
      attribute_mapping = optional(map(string), {})
    }), {})
  })

  default = {}
}

# ==============================================================================
# OPTIONAL VARIABLES - USER POOL USERS
# ==============================================================================
variable "user_pool_users" {
  description = "List of Cognito users to create"
  type = list(object({
    username = string
    email    = string
    password = string
  }))
  default = []
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
variable "user_group_memberships" {
  description = "List of user-to-group memberships"
  type = list(object({
    user  = string
    group = string
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
#  VARIABLES - HOSTED UI
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
# VARIABLES - TAGGING
# ==============================================================================

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
#  VARIABLES - CONDITIONAL RESOURCE CREATION
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

variable "create_resource_servers" {
  description = "Whether to create resource servers"
  type        = bool
  default     = false
}


variable "web_acl_arn" {
  description = "Optional WAF Web ACL ARN to associate with Cognito User Pool. Null = inactive"
  type        = string
  default     = null
}
# ==============================================================================
# VARIABLES - LOG STREAMING
# ==============================================================================
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
  default = null
  validation {
    condition     = var.cognito_log_delivery_config == null || contains(["cloudwatch", "s3", "firehose"], var.cognito_log_delivery_config.log_destination_type)
    error_message = "log_destination_type must be one of: cloudwatch, s3, firehose."
  }

  validation {
    condition     = var.cognito_log_delivery_config == null || contains(["ERROR", "INFO"], var.cognito_log_delivery_config.log_level)
    error_message = "log_level must be either ERROR or INFO."
  }
}
