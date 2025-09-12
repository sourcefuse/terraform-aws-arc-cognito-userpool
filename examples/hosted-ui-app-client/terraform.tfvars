# ==============================================================================
# General Configuration
# ==============================================================================
aws_region   = "us-east-1"
namespace    = "arc"
environment  = "dev"
project_name = "cognito-hosted-ui"

# ==============================================================================
# Hosted UI Configuration
# ==============================================================================
# If you want Hosted UI enabled, set hosted_ui_config = { ... }
# If you don’t want Hosted UI, just set hosted_ui_config = null

hosted_ui_config = {
  name          = "arc-hosted-ui"
  domain        = "arc-dev-auth"
  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/logout"]

  # Optional (defaults provided in variables.tf)
  default_redirect_uri                 = "http://localhost:3000/callback"
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers         = ["COGNITO"]

  # Optional settings
  generate_secret = false
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxx"
  #   css_file        = ""
  image_file = "arc-logo.png"
}

# ==============================================================================
# Password Policy
# ==============================================================================
password_minimum_length          = 8
password_require_lowercase       = true
password_require_numbers         = true
password_require_symbols         = true
password_require_uppercase       = true
temporary_password_validity_days = 7

# ==============================================================================
# Security
# ==============================================================================
mfa_configuration = "OFF"
