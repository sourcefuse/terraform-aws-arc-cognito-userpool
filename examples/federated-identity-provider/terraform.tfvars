aws_region   = "us-east-1"
project_name = "arc"
environment  = "dev"

# Hosted UI
create_hosted_ui_domain = true
hosted_ui_domain_prefix = null
callback_urls           = ["http://localhost:3000/callback"]
logout_urls             = ["http://localhost:3000/logout"]
default_redirect_uri    = "http://localhost:3000/callback"

# OAuth settings
allowed_oauth_flows  = ["code", "implicit"]
allowed_oauth_scopes = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]

# Example Google provider
identity_providers_config = {
  google = {
    enabled       = true
    client_id     = "634973445926-v57p8apbi3ibo5qoqs8r3ccjm6otf23q.apps.googleusercontent.com"
    client_secret = "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"
    scopes        = ["openid", "email", "profile"]
    attribute_mapping = {
      email              = "email"
      family_name        = "family_name"
      given_name         = "given_name"
      name               = "name"
      picture            = "picture"
      preferred_username = "sub"
      username           = "sub"
    }
  }
}


# Password policy
password_minimum_length          = 8
password_require_lowercase       = true
password_require_numbers         = true
password_require_symbols         = true
password_require_uppercase       = true
temporary_password_validity_days = 7

# Security
mfa_configuration = "OFF"
user_pool_tier    = "PLUS"
