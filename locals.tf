# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  # Conditional resource creation flags
  create_user_pool_clients  = var.create_user_pool_clients && length(var.user_pool_clients) > 0
  create_user_pool_domain   = var.create_user_pool_domain && var.user_pool_domain != null
  create_identity_providers = var.create_identity_providers && length(var.identity_providers) > 0
  create_user_pool_groups   = var.create_user_pool_groups && length(var.user_pool_groups) > 0
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

  # User pool clients with defaults applied
  user_pool_clients = [
    for client in var.user_pool_clients : {
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
  ]
}
