# ==============================================================================
# BASIC COGNITO USER POOL EXAMPLE
# ==============================================================================

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example = "basic-user-pool"
    Repo    = "github.com/your-org/terraform-aws-cognito-user-pool"
  }
}

module "cognito_user_pool" {
  source = "../../"

  # Basic configuration
  name = "${var.namespace}-${var.environment}-user-pool"

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

  # Admin user creation settings
  admin_create_user_config = {
    allow_admin_create_user_only = var.allow_admin_create_user_only
    invite_message_template = {
      email_subject = "Welcome to ${var.project_name}!"
      email_message = "Hello {username}, your temporary password is {####}. Please sign in and change your password."
      sms_message   = "Hello {username}, your temporary password is {####}"
    }
  }

  # Email configuration
  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Verification messages
  email_verification_subject = "Verify your email for ${var.project_name}"
  email_verification_message = "Please click the link below to verify your email address: {####}"

  # User pool clients
  user_pool_clients = [
    {
      name            = "${var.namespace}-${var.environment}-web-client"
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_ADMIN_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      access_token_validity         = 60 # 1 hour
      id_token_validity             = 60 # 1 hour
      refresh_token_validity        = 30 # 30 days
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    },
    {
      name            = "${var.namespace}-${var.environment}-test-client"
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_ADMIN_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      access_token_validity         = 60 # 1 hour
      id_token_validity             = 60 # 1 hour
      refresh_token_validity        = 30 # 30 days
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    }
  ]

  # MFA Configuration
  mfa_configuration = var.mfa_configuration

  # Software token MFA (TOTP) - Google Authenticator, etc.
  software_token_mfa_configuration = var.enable_software_token_mfa ? {
    enabled = true
  } : null

  # Device configuration for remember device
  device_configuration = {
    challenge_required_on_new_device      = var.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_only_remembered_on_user_prompt
  }

  # Security settings
  advanced_security_mode = var.advanced_security_mode

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags from arc-tags module
  tags = module.tags.tags
}
