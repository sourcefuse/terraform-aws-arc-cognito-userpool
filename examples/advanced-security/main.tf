# ==============================================================================
# ADVANCED SECURITY COGNITO USER POOL EXAMPLE
# ==============================================================================
# NOTE: This example requires ADVANCED pricing tier in your AWS account

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name

}

module "cognito_user_pool" {
  source = "../../"

  name = "${var.namespace}-${var.environment}-secure-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  user_pool_tier           = var.user_pool_tier

  password_policy = {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  email_verification_subject = "Verify your email for ${var.project_name}"
  email_verification_message = "Please click the link below to verify your email address: {####}"

  user_pool_clients = [
    {
      name            = "${var.namespace}-${var.environment}-secure-client"
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      access_token_validity         = 30
      id_token_validity             = 30
      refresh_token_validity        = 7
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    }
  ]
  #Risk_configuration
  user_pool_add_ons                   = var.user_pool_add_ons
  account_takeover_risk_configuration = var.account_takeover_risk_configuration

  compromised_credentials_risk_configuration = var.compromised_credentials_risk_configuration

  risk_exception_configuration = var.risk_exception_configuration
  cognito_log_delivery_config  = var.cognito_log_delivery_config

  device_configuration = {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  username_configuration = {
    case_sensitive = false
  }

  mfa_configuration                = var.mfa_configuration
  software_token_mfa_configuration = var.software_token_mfa_configuration

  tags = module.tags.tags
}
