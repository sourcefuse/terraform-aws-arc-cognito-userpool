# ==============================================================================
# FEDERATED IDENTITY PROVIDER COGNITO USER POOL EXAMPLE
# ==============================================================================

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Example     = "federated-identity-provider"
  }

  # Build list of supported identity providers
  supported_identity_providers = concat(
    ["COGNITO"],
    var.enable_google_provider ? ["Google"] : [],
    var.enable_facebook_provider ? ["Facebook"] : [],
    var.enable_apple_provider ? ["SignInWithApple"] : [],
    var.enable_amazon_provider ? ["LoginWithAmazon"] : [],
    var.enable_saml_provider ? [var.saml_provider_name] : [],
    var.enable_oidc_provider ? [var.oidc_provider_name] : []
  )

  # Build identity providers list
  identity_providers = concat(
    # Google provider
    var.enable_google_provider ? [{
      provider_name = "Google"
      provider_type = "Google"
      provider_details = {
        client_id                     = var.google_client_id
        client_secret                 = var.google_client_secret
        authorize_scopes              = join(" ", var.google_scopes)
        attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
        attributes_url_add_attributes = "true"
        authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
        oidc_issuer                   = "https://accounts.google.com"
        token_request_method          = "POST"
        token_url                     = "https://www.googleapis.com/oauth2/v4/token"
      }
      attribute_mapping = var.google_attribute_mapping
    }] : [],

    # Facebook provider
    var.enable_facebook_provider ? [{
      provider_name = "Facebook"
      provider_type = "Facebook"
      provider_details = {
        client_id                     = var.facebook_app_id
        client_secret                 = var.facebook_app_secret
        authorize_scopes              = join(",", var.facebook_scopes)
        attributes_url                = "https://graph.facebook.com/v17.0/me?fields="
        attributes_url_add_attributes = "true"
        authorize_url                 = "https://www.facebook.com/v17.0/dialog/oauth"
        token_request_method          = "GET"
        token_url                     = "https://graph.facebook.com/v17.0/oauth/access_token"
      }
      attribute_mapping = var.facebook_attribute_mapping
    }] : [],

    # Apple provider
    var.enable_apple_provider ? [{
      provider_name = "SignInWithApple"
      provider_type = "SignInWithApple"
      provider_details = {
        client_id        = var.apple_services_id
        team_id          = var.apple_team_id
        key_id           = var.apple_key_id
        private_key      = var.apple_private_key
        authorize_scopes = join(" ", var.apple_scopes)
      }
      attribute_mapping = var.apple_attribute_mapping
    }] : [],

    # Amazon provider
    var.enable_amazon_provider ? [{
      provider_name = "LoginWithAmazon"
      provider_type = "LoginWithAmazon"
      provider_details = {
        client_id        = var.amazon_client_id
        client_secret    = var.amazon_client_secret
        authorize_scopes = join(" ", var.amazon_scopes)
      }
      attribute_mapping = var.amazon_attribute_mapping
    }] : [],

    # SAML provider
    var.enable_saml_provider ? [{
      provider_name = var.saml_provider_name
      provider_type = "SAML"
      provider_details = {
        MetadataURL = var.saml_metadata_url
      }
      attribute_mapping = var.saml_attribute_mapping
      idp_identifiers   = var.saml_idp_identifiers
    }] : [],

    # OIDC provider
    var.enable_oidc_provider ? [{
      provider_name = var.oidc_provider_name
      provider_type = "OIDC"
      provider_details = {
        client_id                 = var.oidc_client_id
        client_secret             = var.oidc_client_secret
        attributes_request_method = "GET"
        oidc_issuer               = var.oidc_issuer_url
        authorize_scopes          = join(" ", var.oidc_scopes)
      }
      attribute_mapping = var.oidc_attribute_mapping
    }] : []
  )
}

# ==============================================================================
# COGNITO USER POOL MODULE
# ==============================================================================

module "cognito_user_pool" {
  source = "../.."

  # Basic configuration
  name           = "${local.name_prefix}-federated-pool"
  user_pool_tier = var.user_pool_tier
  # Authentication settings
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy (for Cognito native users)
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

  # Verification message template
  verification_message_template = {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject         = "Verify your email for ${var.project_name}"
    email_message         = "Please click the link below to verify your email address: {####}"
    email_subject_by_link = "Verify your email for ${var.project_name}"
    email_message_by_link = "Please click the link below to verify your email address: {##Click Here##}"
  }

  # User pool clients with OAuth configuration
  user_pool_clients = [
    {
      name                = "${local.name_prefix}-web-client"
      generate_secret     = var.generate_client_secret
      explicit_auth_flows = var.explicit_auth_flows

      # OAuth 2.0 configuration
      allowed_oauth_flows                  = var.allowed_oauth_flows
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = var.allowed_oauth_scopes

      # Callback and logout URLs
      callback_urls        = var.callback_urls
      default_redirect_uri = var.default_redirect_uri
      logout_urls          = var.logout_urls

      # Identity providers (includes federated providers)
      supported_identity_providers = local.supported_identity_providers

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

  # Create hosted UI domain
  create_user_pool_domain = var.create_hosted_ui_domain
  user_pool_domain = var.create_hosted_ui_domain ? {
    domain = var.hosted_ui_domain_prefix != null ? var.hosted_ui_domain_prefix : "${local.name_prefix}-auth"
  } : null

  # Create identity providers
  create_identity_providers = length(local.identity_providers) > 0
  identity_providers        = local.identity_providers

  # Security settings
  advanced_security_mode = var.advanced_security_mode
  mfa_configuration      = var.mfa_configuration

  # Software token MFA (if enabled)
  software_token_mfa_configuration = var.mfa_configuration != "OFF" ? {
    enabled = true
  } : null

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags
  tags = local.common_tags
}
