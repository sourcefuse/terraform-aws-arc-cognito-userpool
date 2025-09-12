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

  # Hosted UI configuration (optional)
  hosted_ui_config = var.hosted_ui_config

  # Security settings
  mfa_configuration = var.mfa_configuration

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags
  tags = module.tags.tags
}
