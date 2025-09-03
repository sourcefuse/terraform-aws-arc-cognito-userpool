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

  # User Pool Add-ons (Threat Detection / Security)
  dynamic "user_pool_add_ons" {
    for_each = var.user_pool_add_ons != null ? [var.user_pool_add_ons] : []
    content {
      advanced_security_mode = user_pool_add_ons.value.advanced_security_mode

      dynamic "advanced_security_additional_flows" {
        for_each = user_pool_add_ons.value.advanced_security_additional_flows != null ? [user_pool_add_ons.value.advanced_security_additional_flows] : []
        content {
          custom_auth_mode = advanced_security_additional_flows.value.custom_auth_mode
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
  # Account recovery mechanism
  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.account_recovery_mechanisms
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }
  # Admin Create user config
  dynamic "admin_create_user_config" {
    for_each = length(var.admin_create_user_config) > 0 ? [var.admin_create_user_config] : []
    content {
      allow_admin_create_user_only = lookup(admin_create_user_config.value, "allow_admin_create_user_only", false)

      dynamic "invite_message_template" {
        for_each = length(lookup(admin_create_user_config.value, "invite_message_template", {})) > 0 ? [lookup(admin_create_user_config.value, "invite_message_template", {})] : []
        content {
          email_message = lookup(invite_message_template.value, "email_message", null)
          email_subject = lookup(invite_message_template.value, "email_subject", null)
          sms_message   = lookup(invite_message_template.value, "sms_message", null)
        }
      }
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
    ignore_changes = [schema]
  }
}

# ==============================================================================
# USER POOL CLIENTS
# ==============================================================================
resource "aws_cognito_user_pool_client" "this" {
  for_each = local.create_user_pool_clients ? local.user_pool_clients : {}

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  access_token_validity  = each.value.access_token_validity
  id_token_validity      = each.value.id_token_validity
  refresh_token_validity = each.value.refresh_token_validity

  dynamic "token_validity_units" {
    for_each = each.value.token_validity_units != null ? [each.value.token_validity_units] : []
    content {
      access_token  = token_validity_units.value.access_token
      id_token      = token_validity_units.value.id_token
      refresh_token = token_validity_units.value.refresh_token
    }
  }

  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  callback_urls                        = each.value.callback_urls
  default_redirect_uri                 = each.value.default_redirect_uri
  logout_urls                          = each.value.logout_urls

  explicit_auth_flows           = each.value.explicit_auth_flows
  generate_secret               = each.value.generate_secret
  prevent_user_existence_errors = each.value.prevent_user_existence_errors

  read_attributes  = each.value.read_attributes
  write_attributes = each.value.write_attributes

  supported_identity_providers = [
    for p in local.identity_providers : p.provider_name
  ]


  enable_token_revocation                       = each.value.enable_token_revocation
  enable_propagate_additional_user_context_data = each.value.enable_propagate_additional_user_context_data
  auth_session_validity                         = each.value.auth_session_validity

  depends_on = [aws_cognito_user_pool.this, aws_cognito_identity_provider.this]
}
resource "aws_cognito_user_pool_client" "hosted_ui" {
  for_each = var.hosted_ui_config != null ? {
    "hosted_ui_client" = var.hosted_ui_config
  } : {}

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  supported_identity_providers         = each.value.supported_identity_providers

  callback_urls        = each.value.callback_urls
  logout_urls          = each.value.logout_urls
  default_redirect_uri = try(each.value.default_redirect_uri, null)

  generate_secret = each.value.generate_secret

  depends_on = [
    aws_cognito_user_pool.this,
    aws_cognito_identity_provider.this
  ]
}
resource "aws_cognito_user_pool_ui_customization" "hosted_ui" {
  for_each = var.hosted_ui_config != null && (
    var.hosted_ui_config.css_file != null ||
    var.hosted_ui_config.image_file != null
    ) ? {
    "hosted_ui_customization" = var.hosted_ui_config
  } : {}

  user_pool_id = aws_cognito_user_pool.this.id
  client_id    = aws_cognito_user_pool_client.hosted_ui["hosted_ui_client"].id

  css        = try(file(each.value.css_file), null)
  image_file = try(filebase64(each.value.image_file), null)
}


# ==============================================================================
# USER POOL DOMAIN
# ==============================================================================
resource "aws_cognito_user_pool_domain" "this" {
  for_each = local.create_user_pool_domain ? {
    (var.user_pool_domain.domain) = var.user_pool_domain
  } : {}

  domain          = each.value.domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = try(each.value.certificate_arn, null)

  depends_on = [aws_cognito_user_pool.this]
}
resource "aws_cognito_user_pool_domain" "hosted_ui" {
  for_each = var.hosted_ui_config != null ? {
    (var.hosted_ui_config.domain) = var.hosted_ui_config
  } : {}

  domain          = each.value.domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = try(each.value.certificate_arn, null)

  depends_on = [aws_cognito_user_pool.this]
}


# ==============================================================================
# IDENTITY PROVIDERS
# ==============================================================================
resource "aws_cognito_identity_provider" "this" {
  for_each = local.create_identity_providers ? {
    for idp in local.identity_providers : idp.provider_name => idp
  } : {}

  user_pool_id      = aws_cognito_user_pool.this.id
  provider_name     = each.value.provider_name
  provider_type     = each.value.provider_type
  provider_details  = each.value.provider_details
  attribute_mapping = each.value.attribute_mapping
  idp_identifiers   = try(each.value.idp_identifiers, null)

  depends_on = [aws_cognito_user_pool.this]
}
# ==============================================================================
# USER POOL USERS
# ==============================================================================
resource "aws_cognito_user" "users" {
  for_each = var.create_user_pool_users ? {
    for u in var.user_pool_users : u.username => u
  } : {}

  user_pool_id       = aws_cognito_user_pool.this.id
  username           = each.value.username
  temporary_password = each.value.password

  attributes = {
    email = each.value.email
  }
}

# ==============================================================================
# USER POOL GROUPS
# ==============================================================================
resource "aws_cognito_user_group" "this" {
  for_each = var.create_user_pool_groups ? {
    for g in var.user_pool_groups : g.name => g
  } : {}

  user_pool_id = aws_cognito_user_pool.this.id
  name         = each.value.name
  description  = try(each.value.description, null)
  precedence   = try(each.value.precedence, null)
  role_arn     = try(each.value.role_arn, null)
}

resource "aws_cognito_user_in_group" "this" {
  for_each = {
    for m in var.user_group_memberships : "${m.user}:${m.group}" => m
    if var.create_user_pool_groups && var.create_user_pool_users
  }

  user_pool_id = aws_cognito_user_pool.this.id
  username     = aws_cognito_user.users[each.value.user].username
  group_name   = aws_cognito_user_group.this[each.value.group].name

  depends_on = [
    aws_cognito_user.users,
    aws_cognito_user_group.this
  ]
}

# ==============================================================================
# RESOURCE SERVERS
# ==============================================================================
resource "aws_cognito_resource_server" "this" {
  for_each = local.create_resource_servers ? {
    for rs in var.resource_servers : rs.identifier => rs
  } : {}

  identifier   = each.value.identifier
  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = each.value.scope
    content {
      scope_name        = scope.value.scope_name
      scope_description = scope.value.scope_description
    }
  }

  depends_on = [aws_cognito_user_pool.this]
}

# ==============================================================================
# WAFv2 WEB ACL (Optional)
# ==============================================================================
resource "aws_wafv2_web_acl_association" "cognito_waf" {
  count        = var.web_acl_arn != null ? 1 : 0
  resource_arn = aws_cognito_user_pool.this.arn
  web_acl_arn  = var.web_acl_arn
}

# ==============================================================================
# LOG STREAMING
# ==============================================================================
resource "aws_cognito_log_delivery_configuration" "this" {
  count        = var.cognito_log_delivery_config == null ? 0 : 1
  user_pool_id = aws_cognito_user_pool.this.id

  log_configurations {
    event_source = var.cognito_log_delivery_config.event_source
    log_level    = var.cognito_log_delivery_config.log_level

    dynamic "cloud_watch_logs_configuration" {
      for_each = var.cognito_log_delivery_config != null && var.cognito_log_delivery_config.log_destination_type == "cloudwatch" ? [1] : []
      content {
        log_group_arn = aws_cloudwatch_log_group.this[0].arn
      }
    }

    dynamic "s3_configuration" {
      for_each = var.cognito_log_delivery_config != null && var.cognito_log_delivery_config.log_destination_type == "s3" ? [1] : []
      content {
        bucket_arn = aws_s3_bucket.this["create"].arn
      }
    }

    dynamic "firehose_configuration" {
      for_each = var.cognito_log_delivery_config != null && var.cognito_log_delivery_config.log_destination_type == "firehose" ? [1] : []
      content {
        stream_arn = var.cognito_log_delivery_config.firehose_stream_arn
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.cognito_log_delivery_config != null && var.cognito_log_delivery_config.log_destination_type == "cloudwatch" ? 1 : 0
  name              = coalesce(var.cognito_log_delivery_config.log_group_name, "cognito-log-group")
  retention_in_days = 30
}

resource "aws_s3_bucket" "this" {
  for_each = var.cognito_log_delivery_config != null && var.cognito_log_delivery_config.log_destination_type == "s3" ? { create = true } : {}

  bucket        = var.cognito_log_delivery_config.s3_bucket_name
  force_destroy = true
}

# ==============================================================================
# Threat Detection
# ==============================================================================
resource "aws_cognito_risk_configuration" "this" {
  count = (
    var.account_takeover_risk_configuration != null ||
    var.compromised_credentials_risk_configuration != null ||
    var.risk_exception_configuration != null
  ) ? 1 : 0
  user_pool_id = aws_cognito_user_pool.this.id
  client_id    = "ALL"

  dynamic "account_takeover_risk_configuration" {
    for_each = var.account_takeover_risk_configuration != null ? [var.account_takeover_risk_configuration] : []
    content {
      notify_configuration {
        from       = lookup(account_takeover_risk_configuration.value.notify_configuration, "from", null)
        reply_to   = lookup(account_takeover_risk_configuration.value.notify_configuration, "reply_to", null)
        source_arn = account_takeover_risk_configuration.value.notify_configuration.source_arn

        dynamic "block_email" {
          for_each = lookup(account_takeover_risk_configuration.value.notify_configuration, "block_email", null) != null ? [account_takeover_risk_configuration.value.notify_configuration.block_email] : []
          content {
            html_body = block_email.value.html_body
            text_body = block_email.value.text_body
            subject   = block_email.value.subject
          }
        }

        dynamic "mfa_email" {
          for_each = lookup(account_takeover_risk_configuration.value.notify_configuration, "mfa_email", null) != null ? [account_takeover_risk_configuration.value.notify_configuration.mfa_email] : []
          content {
            html_body = mfa_email.value.html_body
            text_body = mfa_email.value.text_body
            subject   = mfa_email.value.subject
          }
        }

        dynamic "no_action_email" {
          for_each = lookup(account_takeover_risk_configuration.value.notify_configuration, "no_action_email", null) != null ? [account_takeover_risk_configuration.value.notify_configuration.no_action_email] : []
          content {
            html_body = no_action_email.value.html_body
            text_body = no_action_email.value.text_body
            subject   = no_action_email.value.subject
          }
        }
      }

      actions {
        high_action {
          event_action = lookup(account_takeover_risk_configuration.value.actions.high_action, "event_action", null)
          notify       = lookup(account_takeover_risk_configuration.value.actions.high_action, "notify", null)
        }
        medium_action {
          event_action = lookup(account_takeover_risk_configuration.value.actions.medium_action, "event_action", null)
          notify       = lookup(account_takeover_risk_configuration.value.actions.medium_action, "notify", null)
        }
        low_action {
          event_action = lookup(account_takeover_risk_configuration.value.actions.low_action, "event_action", null)
          notify       = lookup(account_takeover_risk_configuration.value.actions.low_action, "notify", null)
        }
      }
    }
  }

  dynamic "compromised_credentials_risk_configuration" {
    for_each = var.compromised_credentials_risk_configuration != null ? [var.compromised_credentials_risk_configuration] : []
    content {
      event_filter = lookup(compromised_credentials_risk_configuration.value, "event_filter", null)

      actions {
        event_action = compromised_credentials_risk_configuration.value.actions.event_action
      }
    }
  }

  dynamic "risk_exception_configuration" {
    for_each = var.risk_exception_configuration != null ? [var.risk_exception_configuration] : []
    content {
      blocked_ip_range_list = lookup(risk_exception_configuration.value, "blocked_ip_range_list", null)
      skipped_ip_range_list = lookup(risk_exception_configuration.value, "skipped_ip_range_list", null)
    }
  }
}
