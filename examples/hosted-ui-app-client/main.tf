# ==============================================================================
# HOSTED UI COGNITO USER POOL EXAMPLE
# ==============================================================================

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name
}

module "cognito_user_pool" {
  source = "../../"

  # Basic configuration
  name = "${var.namespace}-${var.environment}-hosted-ui-pool"

  # Authentication settings
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy = {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # Account recovery
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  # Email configuration
  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Verification messages
  email_verification_subject = "Verify your email for ${var.project_name}"
  email_verification_message = "Please click the link below to verify your email address: {####}"

  # User pool clients with OAuth configuration for Hosted UI
  user_pool_clients = [
    {
      name            = "${var.namespace}-${var.environment}-hosted-ui-client"
      generate_secret = var.generate_client_secret

      # Auth flows for hosted UI
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]

      # OAuth 2.0 configuration - REQUIRED for Hosted UI
      allowed_oauth_flows                  = var.allowed_oauth_flows
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = var.allowed_oauth_scopes

      # Callback and logout URLs - REQUIRED for Hosted UI
      callback_urls        = var.callback_urls
      default_redirect_uri = var.default_redirect_uri
      logout_urls          = var.logout_urls

      # Identity providers
      supported_identity_providers = var.supported_identity_providers

      # Token validity
      access_token_validity  = var.access_token_validity
      id_token_validity      = var.id_token_validity
      refresh_token_validity = var.refresh_token_validity

      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }

      # Security settings
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true

      # Attribute access
      read_attributes  = var.read_attributes
      write_attributes = var.write_attributes
    }
  ]

  # Create hosted UI domain - REQUIRED for Hosted UI
  create_user_pool_domain = var.create_hosted_ui_domain
  user_pool_domain = var.create_hosted_ui_domain ? {
    domain = var.hosted_ui_domain_prefix != null ? var.hosted_ui_domain_prefix : "${var.namespace}-${var.environment}-auth"
  } : null

  # User groups for role-based access
  create_user_pool_groups = var.create_user_groups
  user_pool_groups = var.create_user_groups ? [
    {
      name        = "admin"
      description = "Administrator group with full access"
      precedence  = 1
    },
    {
      name        = "user"
      description = "Standard user group"
      precedence  = 2
    }
  ] : []

  # Security settings
  advanced_security_mode = var.advanced_security_mode
  mfa_configuration      = var.mfa_configuration

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags
  tags = module.tags.tags
}
