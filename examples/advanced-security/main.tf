# ==============================================================================
# ADVANCED SECURITY COGNITO USER POOL EXAMPLE
# ==============================================================================
# NOTE: This example requires ADVANCED pricing tier in your AWS account

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example = "advanced-security"
    Repo    = "github.com/your-org/terraform-aws-cognito-user-pool"
    Tier    = "ADVANCED"
  }
}

module "cognito_user_pool" {
  source = "../../"

  # Basic configuration
  name = "${var.namespace}-${var.environment}-secure-pool"

  # Authentication settings
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy - stronger for advanced security
  password_policy = {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
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

  # User pool clients with enhanced security
  user_pool_clients = [
    {
      name            = "${var.namespace}-${var.environment}-secure-client"
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      access_token_validity         = 30 # 30 minutes for security
      id_token_validity             = 30 # 30 minutes for security
      refresh_token_validity        = 7  # 7 days
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    }
  ]

  # ADVANCED SECURITY FEATURES (Requires ADVANCED pricing tier)
  advanced_security_mode           = var.advanced_security_mode
  mfa_configuration                = var.mfa_configuration
  software_token_mfa_configuration = var.software_token_mfa_configuration
  # Device configuration for remember device
  device_configuration = {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags
  tags = module.tags.tags
}
