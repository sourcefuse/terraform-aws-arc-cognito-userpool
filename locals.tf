# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  # Conditional resource creation flags
  create_user_pool_clients  = var.create_user_pool_clients && length(var.user_pool_clients) > 0
  create_user_pool_domain   = var.create_user_pool_domain && var.user_pool_domain != null
  create_identity_providers = length(local.identity_providers) > 0
  create_resource_servers   = var.create_resource_servers && length(var.resource_servers) > 0

  # Lambda configuration with conditional blocks
  lambda_config = var.lambda_config != null ? {
    create_auth_challenge          = var.lambda_config.create_auth_challenge
    custom_message                 = var.lambda_config.custom_message
    define_auth_challenge          = var.lambda_config.define_auth_challenge
    post_authentication            = var.lambda_config.post_authentication
    post_confirmation              = var.lambda_config.post_confirmation
    pre_authentication             = var.lambda_config.pre_authentication
    pre_sign_up                    = var.lambda_config.pre_sign_up
    pre_token_generation           = var.lambda_config.pre_token_generation
    user_migration                 = var.lambda_config.user_migration
    verify_auth_challenge_response = var.lambda_config.verify_auth_challenge_response
    kms_key_id                     = var.lambda_config.kms_key_id
    custom_email_sender            = var.lambda_config.custom_email_sender
    custom_sms_sender              = var.lambda_config.custom_sms_sender
    pre_token_generation_config    = var.lambda_config.pre_token_generation_config
  } : null

  # User pool clients (map for for_each)
  user_pool_clients = {
    for client in var.user_pool_clients : client.name => {
      name                                          = client.name
      access_token_validity                         = client.access_token_validity
      id_token_validity                             = client.id_token_validity
      refresh_token_validity                        = client.refresh_token_validity
      token_validity_units                          = client.token_validity_units
      allowed_oauth_flows                           = client.allowed_oauth_flows
      allowed_oauth_flows_user_pool_client          = client.allowed_oauth_flows_user_pool_client
      allowed_oauth_scopes                          = client.allowed_oauth_scopes
      callback_urls                                 = client.callback_urls
      default_redirect_uri                          = client.default_redirect_uri
      explicit_auth_flows                           = client.explicit_auth_flows
      generate_secret                               = client.generate_secret
      logout_urls                                   = client.logout_urls
      prevent_user_existence_errors                 = client.prevent_user_existence_errors
      read_attributes                               = client.read_attributes
      supported_identity_providers                  = client.supported_identity_providers
      write_attributes                              = client.write_attributes
      enable_token_revocation                       = client.enable_token_revocation
      enable_propagate_additional_user_context_data = client.enable_propagate_additional_user_context_data
      auth_session_validity                         = client.auth_session_validity
    }
  }

  # Build full identity providers configuration
  identity_providers = concat(
    var.identity_providers_config.google.enabled ? [{
      provider_name = "Google"
      provider_type = "Google"
      provider_details = {
        client_id                     = var.identity_providers_config.google.client_id
        client_secret                 = var.identity_providers_config.google.client_secret
        authorize_scopes              = join(" ", var.identity_providers_config.google.scopes)
        authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
        token_url                     = "https://www.googleapis.com/oauth2/v4/token"
        attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
        attributes_url_add_attributes = "true"
        oidc_issuer                   = "https://accounts.google.com"
        token_request_method          = "POST"
      }
      attribute_mapping = var.identity_providers_config.google.attribute_mapping
    }] : [],

    var.identity_providers_config.facebook.enabled ? [{
      provider_name = "Facebook"
      provider_type = "Facebook"
      provider_details = {
        client_id                     = var.identity_providers_config.facebook.app_id
        client_secret                 = var.identity_providers_config.facebook.app_secret
        authorize_scopes              = join(",", var.identity_providers_config.facebook.scopes)
        authorize_url                 = "https://www.facebook.com/v17.0/dialog/oauth"
        token_url                     = "https://graph.facebook.com/v17.0/oauth/access_token"
        attributes_url                = "https://graph.facebook.com/v17.0/me?fields="
        attributes_url_add_attributes = "true"
        token_request_method          = "GET"
      }
      attribute_mapping = var.identity_providers_config.facebook.attribute_mapping
    }] : [],

    var.identity_providers_config.apple.enabled ? [{
      provider_name = "SignInWithApple"
      provider_type = "SignInWithApple"
      provider_details = {
        client_id        = var.identity_providers_config.apple.services_id
        team_id          = var.identity_providers_config.apple.team_id
        key_id           = var.identity_providers_config.apple.key_id
        private_key      = var.identity_providers_config.apple.private_key
        authorize_scopes = join(" ", var.identity_providers_config.apple.scopes)
      }
      attribute_mapping = var.identity_providers_config.apple.attribute_mapping
    }] : [],

    var.identity_providers_config.amazon.enabled ? [{
      provider_name = "LoginWithAmazon"
      provider_type = "LoginWithAmazon"
      provider_details = {
        client_id        = var.identity_providers_config.amazon.client_id
        client_secret    = var.identity_providers_config.amazon.client_secret
        authorize_scopes = join(" ", var.identity_providers_config.amazon.scopes)
      }
      attribute_mapping = var.identity_providers_config.amazon.attribute_mapping
    }] : [],

    var.identity_providers_config.saml.enabled ? [{
      provider_name     = var.identity_providers_config.saml.provider_name
      provider_type     = "SAML"
      provider_details  = { MetadataURL = var.identity_providers_config.saml.metadata_url }
      attribute_mapping = var.identity_providers_config.saml.attribute_mapping
      idp_identifiers   = var.identity_providers_config.saml.idp_identifiers
    }] : [],

    var.identity_providers_config.oidc.enabled ? [{
      provider_name = var.identity_providers_config.oidc.provider_name
      provider_type = "OIDC"
      provider_details = {
        client_id                 = var.identity_providers_config.oidc.client_id
        client_secret             = var.identity_providers_config.oidc.client_secret
        oidc_issuer               = var.identity_providers_config.oidc.issuer_url
        authorize_scopes          = join(" ", var.identity_providers_config.oidc.scopes)
        attributes_request_method = "GET"
      }
      attribute_mapping = var.identity_providers_config.oidc.attribute_mapping
    }] : []
  )
}
