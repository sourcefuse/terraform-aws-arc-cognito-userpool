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
}

# ==============================================================================
# CALL ROOT MODULE
# ==============================================================================

module "cognito_user_pool" {
  source = "../.." # root module path

  # Basic configuration
  name           = "${local.name_prefix}-federated-pool"
  user_pool_tier = var.user_pool_tier

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy = {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  account_recovery_mechanisms = [{
    name     = "verified_email"
    priority = 1
  }]

  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template = {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject         = "Verify your email for ${var.project_name}"
    email_message         = "Please click the link below to verify your email address: {####}"
    email_subject_by_link = "Verify your email for ${var.project_name}"
    email_message_by_link = "Please click the link below to verify your email address: {##Click Here##}"
  }

  # User pool clients
  user_pool_clients = [
    {
      name                = "${local.name_prefix}-web-client"
      generate_secret     = var.generate_client_secret
      explicit_auth_flows = var.explicit_auth_flows

      allowed_oauth_flows                  = var.allowed_oauth_flows
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = var.allowed_oauth_scopes

      callback_urls          = var.callback_urls
      default_redirect_uri   = var.default_redirect_uri
      logout_urls            = var.logout_urls
      access_token_validity  = var.access_token_validity
      id_token_validity      = var.id_token_validity
      refresh_token_validity = var.refresh_token_validity

      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }

      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true

      read_attributes  = var.read_attributes
      write_attributes = var.write_attributes
    }
  ]

  # Hosted UI domain
  create_user_pool_domain = var.create_hosted_ui_domain
  user_pool_domain = var.create_hosted_ui_domain ? {
    domain = var.hosted_ui_domain_prefix != null ? var.hosted_ui_domain_prefix : "${local.name_prefix}-auth"
  } : null

  # Federated identity providers
  identity_providers_config = var.identity_providers_config

  mfa_configuration = var.mfa_configuration

  software_token_mfa_configuration = var.mfa_configuration != "OFF" ? {
    enabled = true
  } : null

  username_configuration = {
    case_sensitive = false
  }

  tags = local.common_tags
}
