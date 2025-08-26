# ==============================================================================
# USER POOL OUTPUTS
# ==============================================================================

output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_arn
}

output "user_pool_name" {
  description = "The name of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_name
}

output "user_pool_endpoint" {
  description = "The endpoint name of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_endpoint
}

# ==============================================================================
# CLIENT OUTPUTS
# ==============================================================================

output "user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : null
}

output "user_pool_client_name" {
  description = "The name of the Cognito User Pool Client"
  value       = length(module.cognito_user_pool.user_pool_client_names) > 0 ? module.cognito_user_pool.user_pool_client_names[0] : null
}

output "user_pool_client_secret" {
  description = "The client secret of the Cognito User Pool Client (if generated)"
  value       = var.generate_client_secret && length(module.cognito_user_pool.user_pool_client_secrets) > 0 ? module.cognito_user_pool.user_pool_client_secrets[0] : null
  sensitive   = true
}

# ==============================================================================
# HOSTED UI OUTPUTS
# ==============================================================================

output "hosted_ui_domain" {
  description = "The domain name for the hosted UI"
  value       = module.cognito_user_pool.user_pool_domain_name
}

output "hosted_ui_url" {
  description = "The URL of the hosted UI"
  value       = module.cognito_user_pool.user_pool_hosted_ui_url
}

output "login_url" {
  description = "The login URL for the hosted UI"
  value = module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/login?client_id=%s&response_type=code&scope=%s&redirect_uri=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes),
    var.default_redirect_uri
  ) : null
}

output "logout_url" {
  description = "The logout URL for the hosted UI"
  value = module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/logout?client_id=%s&logout_uri=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    length(var.logout_urls) > 0 ? var.logout_urls[0] : ""
  ) : null
}

# ==============================================================================
# IDENTITY PROVIDER OUTPUTS
# ==============================================================================

output "identity_provider_names" {
  description = "The names of the configured identity providers"
  value       = module.cognito_user_pool.identity_provider_names
}

output "supported_identity_providers" {
  description = "List of all supported identity providers"
  value       = local.supported_identity_providers
}

output "enabled_providers" {
  description = "Map of enabled identity providers and their status"
  value = {
    cognito  = true
    google   = var.enable_google_provider
    facebook = var.enable_facebook_provider
    apple    = var.enable_apple_provider
    amazon   = var.enable_amazon_provider
    saml     = var.enable_saml_provider
    oidc     = var.enable_oidc_provider
  }
}

# ==============================================================================
# CONVENIENCE OUTPUTS
# ==============================================================================

output "user_pool_jwks_uri" {
  description = "The JSON Web Key Set (JWKS) URI for the user pool"
  value       = module.cognito_user_pool.user_pool_jwks_uri
}

output "user_pool_issuer" {
  description = "The issuer URL for the user pool"
  value       = module.cognito_user_pool.user_pool_issuer
}

# ==============================================================================
# PROVIDER-SPECIFIC LOGIN URLS
# ==============================================================================

output "google_login_url" {
  description = "Direct login URL for Google provider"
  value = var.enable_google_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=Google&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

output "facebook_login_url" {
  description = "Direct login URL for Facebook provider"
  value = var.enable_facebook_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=Facebook&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

output "apple_login_url" {
  description = "Direct login URL for Apple provider"
  value = var.enable_apple_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=SignInWithApple&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

output "amazon_login_url" {
  description = "Direct login URL for Amazon provider"
  value = var.enable_amazon_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=LoginWithAmazon&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

output "saml_login_url" {
  description = "Direct login URL for SAML provider"
  value = var.enable_saml_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=%s&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.saml_provider_name,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

output "oidc_login_url" {
  description = "Direct login URL for OIDC provider"
  value = var.enable_oidc_provider && module.cognito_user_pool.user_pool_hosted_ui_url != null ? format(
    "%s/oauth2/authorize?identity_provider=%s&redirect_uri=%s&response_type=code&client_id=%s&scope=%s",
    module.cognito_user_pool.user_pool_hosted_ui_url,
    var.oidc_provider_name,
    var.default_redirect_uri,
    length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : "",
    join("+", var.allowed_oauth_scopes)
  ) : null
}

# ==============================================================================
# OAUTH CONFIGURATION OUTPUTS
# ==============================================================================

output "oauth_configuration" {
  description = "OAuth configuration details for client applications"
  value = {
    client_id                    = length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : null
    client_secret                = var.generate_client_secret && length(module.cognito_user_pool.user_pool_client_secrets) > 0 ? module.cognito_user_pool.user_pool_client_secrets[0] : null
    user_pool_id                 = module.cognito_user_pool.user_pool_id
    hosted_ui_domain             = module.cognito_user_pool.user_pool_domain_name
    hosted_ui_url                = module.cognito_user_pool.user_pool_hosted_ui_url
    jwks_uri                     = module.cognito_user_pool.user_pool_jwks_uri
    issuer                       = module.cognito_user_pool.user_pool_issuer
    allowed_oauth_flows          = var.allowed_oauth_flows
    allowed_oauth_scopes         = var.allowed_oauth_scopes
    callback_urls                = var.callback_urls
    logout_urls                  = var.logout_urls
    supported_identity_providers = local.supported_identity_providers
  }
  sensitive = true
}

# ==============================================================================
# SUMMARY OUTPUT
# ==============================================================================

output "summary" {
  description = "Summary of the created Cognito User Pool with federated identity providers"
  value = {
    user_pool_id     = module.cognito_user_pool.user_pool_id
    user_pool_name   = module.cognito_user_pool.user_pool_name
    client_id        = length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : null
    hosted_ui_domain = module.cognito_user_pool.user_pool_domain_name
    hosted_ui_url    = module.cognito_user_pool.user_pool_hosted_ui_url
    region           = var.aws_region
    environment      = var.environment
    project          = var.project_name
    mfa_enabled      = var.mfa_configuration != "OFF"
    enabled_providers = {
      google   = var.enable_google_provider
      facebook = var.enable_facebook_provider
      apple    = var.enable_apple_provider
      amazon   = var.enable_amazon_provider
      saml     = var.enable_saml_provider
      oidc     = var.enable_oidc_provider
    }
  }
}
