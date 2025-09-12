# ==============================================================================
# BASIC COGNITO USER POOL EXAMPLE
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
  name                = "${var.namespace}-${var.environment}-user-pool"
  user_pool_tier      = var.user_pool_tier
  deletion_protection = var.deletion_protection

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
    password_history_size            = 5
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
  user_pool_clients = var.user_pool_clients

  # MFA Configuration
  mfa_configuration = var.mfa_configuration

  # Authenticator token MFA
  software_token_mfa_configuration = var.software_token_mfa_configuration # Need to be enabled if 'mfa_configuration' is "ON" or "OPTONAL".

  # Device configuration
  device_configuration = {
    challenge_required_on_new_device      = var.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_only_remembered_on_user_prompt
  }

  # Security settings
  user_pool_add_ons = null

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }
  create_user_pool_users  = var.create_user_pool_users
  create_user_pool_groups = var.create_user_pool_groups


  # Example: Pre-creating users
  user_pool_users = var.user_pool_users

  # Example: Groups
  user_pool_groups = var.user_pool_groups

  # Example: Add user to group
  user_group_memberships = var.user_group_memberships

  # Tags
  tags = module.tags.tags
}
