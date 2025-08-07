# ==============================================================================
# COGNITO USER POOL
# ==============================================================================

resource "aws_cognito_user_pool" "this" {
  name                     = var.name
  deletion_protection      = var.deletion_protection
  user_pool_tier           = var.user_pool_tier
  alias_attributes         = length(var.alias_attributes) > 0 ? var.alias_attributes : null
  username_attributes      = length(var.username_attributes) > 0 ? var.username_attributes : null
  auto_verified_attributes = length(var.auto_verified_attributes) > 0 ? var.auto_verified_attributes : null

  # MFA Configuration
  mfa_configuration = var.mfa_configuration

  # Password Policy
  dynamic "password_policy" {
    for_each = var.password_policy != null ? [var.password_policy] : []
    content {
      minimum_length                   = password_policy.value.minimum_length
      require_lowercase                = password_policy.value.require_lowercase
      require_numbers                  = password_policy.value.require_numbers
      require_symbols                  = password_policy.value.require_symbols
      require_uppercase                = password_policy.value.require_uppercase
      temporary_password_validity_days = password_policy.value.temporary_password_validity_days
      password_history_size            = password_policy.value.password_history_size
    }
  }

  # Advanced Security Configuration
  dynamic "user_pool_add_ons" {
    for_each = var.advanced_security_mode != "OFF" ? [1] : []
    content {
      advanced_security_mode = var.advanced_security_mode

      dynamic "advanced_security_additional_flows" {
        for_each = var.custom_auth_mode != null ? [1] : []
        content {
          custom_auth_mode = var.custom_auth_mode
        }
      }
    }
  }

  # Account Recovery Settings
  dynamic "account_recovery_setting" {
    for_each = length(var.account_recovery_mechanisms) > 0 ? [1] : []
    content {
      dynamic "recovery_mechanism" {
        for_each = var.account_recovery_mechanisms
        content {
          name     = recovery_mechanism.value.name
          priority = recovery_mechanism.value.priority
        }
      }
    }
  }

  # Admin Create User Configuration
  dynamic "admin_create_user_config" {
    for_each = var.admin_create_user_config != null ? [var.admin_create_user_config] : []
    content {
      allow_admin_create_user_only = admin_create_user_config.value.allow_admin_create_user_only

      dynamic "invite_message_template" {
        for_each = admin_create_user_config.value.invite_message_template != null ? [admin_create_user_config.value.invite_message_template] : []
        content {
          email_message = invite_message_template.value.email_message
          email_subject = invite_message_template.value.email_subject
          sms_message   = invite_message_template.value.sms_message
        }
      }
    }
  }

  # Device Configuration
  dynamic "device_configuration" {
    for_each = var.device_configuration != null ? [var.device_configuration] : []
    content {
      challenge_required_on_new_device      = device_configuration.value.challenge_required_on_new_device
      device_only_remembered_on_user_prompt = device_configuration.value.device_only_remembered_on_user_prompt
    }
  }

  # Email Configuration
  dynamic "email_configuration" {
    for_each = var.email_configuration != null ? [var.email_configuration] : []
    content {
      configuration_set      = email_configuration.value.configuration_set
      email_sending_account  = email_configuration.value.email_sending_account
      from_email_address     = email_configuration.value.from_email_address
      reply_to_email_address = email_configuration.value.reply_to_email_address
      source_arn             = email_configuration.value.source_arn
    }
  }

  # Email Verification
  email_verification_message = var.email_verification_message
  email_verification_subject = var.email_verification_subject

  # SMS Configuration
  dynamic "sms_configuration" {
    for_each = var.sms_configuration != null ? [var.sms_configuration] : []
    content {
      external_id    = sms_configuration.value.external_id
      sns_caller_arn = sms_configuration.value.sns_caller_arn
      sns_region     = sms_configuration.value.sns_region
    }
  }

  # SMS Messages
  sms_authentication_message = var.sms_authentication_message
  sms_verification_message   = var.sms_verification_message

  # Software Token MFA Configuration
  dynamic "software_token_mfa_configuration" {
    for_each = var.software_token_mfa_configuration != null ? [var.software_token_mfa_configuration] : []
    content {
      enabled = software_token_mfa_configuration.value.enabled
    }
  }

  # Username Configuration
  dynamic "username_configuration" {
    for_each = var.username_configuration != null ? [var.username_configuration] : []
    content {
      case_sensitive = username_configuration.value.case_sensitive
    }
  }

  # User Attribute Update Settings
  dynamic "user_attribute_update_settings" {
    for_each = var.user_attribute_update_settings != null ? [var.user_attribute_update_settings] : []
    content {
      attributes_require_verification_before_update = user_attribute_update_settings.value.attributes_require_verification_before_update
    }
  }

  # Lambda Configuration
  dynamic "lambda_config" {
    for_each = local.lambda_config != null ? [local.lambda_config] : []
    content {
      create_auth_challenge          = lambda_config.value.create_auth_challenge
      custom_message                 = lambda_config.value.custom_message
      define_auth_challenge          = lambda_config.value.define_auth_challenge
      post_authentication            = lambda_config.value.post_authentication
      post_confirmation              = lambda_config.value.post_confirmation
      pre_authentication             = lambda_config.value.pre_authentication
      pre_sign_up                    = lambda_config.value.pre_sign_up
      pre_token_generation           = lambda_config.value.pre_token_generation
      user_migration                 = lambda_config.value.user_migration
      verify_auth_challenge_response = lambda_config.value.verify_auth_challenge_response
      kms_key_id                     = lambda_config.value.kms_key_id

      dynamic "custom_email_sender" {
        for_each = lambda_config.value.custom_email_sender != null ? [lambda_config.value.custom_email_sender] : []
        content {
          lambda_arn     = custom_email_sender.value.lambda_arn
          lambda_version = custom_email_sender.value.lambda_version
        }
      }

      dynamic "custom_sms_sender" {
        for_each = lambda_config.value.custom_sms_sender != null ? [lambda_config.value.custom_sms_sender] : []
        content {
          lambda_arn     = custom_sms_sender.value.lambda_arn
          lambda_version = custom_sms_sender.value.lambda_version
        }
      }

      dynamic "pre_token_generation_config" {
        for_each = lambda_config.value.pre_token_generation_config != null ? [lambda_config.value.pre_token_generation_config] : []
        content {
          lambda_arn     = pre_token_generation_config.value.lambda_arn
          lambda_version = pre_token_generation_config.value.lambda_version
        }
      }
    }
  }

  # Schema Configuration
  dynamic "schema" {
    for_each = var.schema
    content {
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = schema.value.developer_only_attribute
      mutable                  = schema.value.mutable
      name                     = schema.value.name
      required                 = schema.value.required

      dynamic "number_attribute_constraints" {
        for_each = schema.value.number_attribute_constraints != null ? [schema.value.number_attribute_constraints] : []
        content {
          max_value = number_attribute_constraints.value.max_value
          min_value = number_attribute_constraints.value.min_value
        }
      }

      dynamic "string_attribute_constraints" {
        for_each = schema.value.string_attribute_constraints != null ? [schema.value.string_attribute_constraints] : []
        content {
          max_length = string_attribute_constraints.value.max_length
          min_length = string_attribute_constraints.value.min_length
        }
      }
    }
  }

  # Verification Message Template
  dynamic "verification_message_template" {
    for_each = var.verification_message_template != null ? [var.verification_message_template] : []
    content {
      default_email_option  = verification_message_template.value.default_email_option
      email_message         = verification_message_template.value.email_message
      email_message_by_link = verification_message_template.value.email_message_by_link
      email_subject         = verification_message_template.value.email_subject
      email_subject_by_link = verification_message_template.value.email_subject_by_link
      sms_message           = verification_message_template.value.sms_message
    }
  }

  # WebAuthn Configuration
  dynamic "web_authn_configuration" {
    for_each = var.web_authn_configuration != null ? [var.web_authn_configuration] : []
    content {
      relying_party_id  = web_authn_configuration.value.relying_party_id
      user_verification = web_authn_configuration.value.user_verification
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      schema,
    ]
  }
}

# ==============================================================================
# USER POOL CLIENTS
# ==============================================================================

resource "aws_cognito_user_pool_client" "this" {
  count = local.create_user_pool_clients ? length(local.user_pool_clients) : 0

  name         = local.user_pool_clients[count.index].name
  user_pool_id = aws_cognito_user_pool.this.id

  # Token Validity
  access_token_validity  = local.user_pool_clients[count.index].access_token_validity
  id_token_validity      = local.user_pool_clients[count.index].id_token_validity
  refresh_token_validity = local.user_pool_clients[count.index].refresh_token_validity

  dynamic "token_validity_units" {
    for_each = local.user_pool_clients[count.index].token_validity_units != null ? [local.user_pool_clients[count.index].token_validity_units] : []
    content {
      access_token  = token_validity_units.value.access_token
      id_token      = token_validity_units.value.id_token
      refresh_token = token_validity_units.value.refresh_token
    }
  }

  # OAuth Configuration
  allowed_oauth_flows                  = local.user_pool_clients[count.index].allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = local.user_pool_clients[count.index].allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = local.user_pool_clients[count.index].allowed_oauth_scopes
  callback_urls                        = local.user_pool_clients[count.index].callback_urls
  default_redirect_uri                 = local.user_pool_clients[count.index].default_redirect_uri
  logout_urls                          = local.user_pool_clients[count.index].logout_urls

  # Authentication Configuration
  explicit_auth_flows           = local.user_pool_clients[count.index].explicit_auth_flows
  generate_secret               = local.user_pool_clients[count.index].generate_secret
  prevent_user_existence_errors = local.user_pool_clients[count.index].prevent_user_existence_errors

  # Attributes
  read_attributes  = local.user_pool_clients[count.index].read_attributes
  write_attributes = local.user_pool_clients[count.index].write_attributes

  # Identity Providers
  supported_identity_providers = local.user_pool_clients[count.index].supported_identity_providers

  # Additional Settings
  enable_token_revocation                       = local.user_pool_clients[count.index].enable_token_revocation
  enable_propagate_additional_user_context_data = local.user_pool_clients[count.index].enable_propagate_additional_user_context_data
  auth_session_validity                         = local.user_pool_clients[count.index].auth_session_validity

  depends_on = [aws_cognito_user_pool.this]
}

# ==============================================================================
# USER POOL DOMAIN
# ==============================================================================

resource "aws_cognito_user_pool_domain" "this" {
  count = local.create_user_pool_domain ? 1 : 0

  domain          = var.user_pool_domain.domain
  certificate_arn = var.user_pool_domain.certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id

  depends_on = [aws_cognito_user_pool.this]
}

# ==============================================================================
# IDENTITY PROVIDERS
# ==============================================================================

resource "aws_cognito_identity_provider" "this" {
  count = local.create_identity_providers ? length(var.identity_providers) : 0

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = var.identity_providers[count.index].provider_name
  provider_type = var.identity_providers[count.index].provider_type

  provider_details  = var.identity_providers[count.index].provider_details
  attribute_mapping = var.identity_providers[count.index].attribute_mapping
  idp_identifiers   = var.identity_providers[count.index].idp_identifiers

  depends_on = [aws_cognito_user_pool.this]
}

# ==============================================================================
# USER POOL GROUPS
# ==============================================================================

resource "aws_cognito_user_group" "this" {
  count = local.create_user_pool_groups ? length(var.user_pool_groups) : 0

  name         = var.user_pool_groups[count.index].name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = var.user_pool_groups[count.index].description
  precedence   = var.user_pool_groups[count.index].precedence
  role_arn     = var.user_pool_groups[count.index].role_arn

  depends_on = [aws_cognito_user_pool.this]
}

# ==============================================================================
# RESOURCE SERVERS
# ==============================================================================

resource "aws_cognito_resource_server" "this" {
  count = local.create_resource_servers ? length(var.resource_servers) : 0

  identifier   = var.resource_servers[count.index].identifier
  name         = var.resource_servers[count.index].name
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = var.resource_servers[count.index].scope
    content {
      scope_name        = scope.value.scope_name
      scope_description = scope.value.scope_description
    }
  }

  depends_on = [aws_cognito_user_pool.this]
}
