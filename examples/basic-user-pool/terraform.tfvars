# Basic configuration for testing
aws_region   = "us-east-1"
namespace    = "arc"
environment  = "dev"
project_name = "cognito-auth"

# Security settings - use OFF for ESSENTIALS pricing tier
mfa_configuration = "ON"
software_token_mfa_configuration = {
  enabled = true
}
# Password policy settings
password_minimum_length    = 8
password_require_lowercase = true
password_require_numbers   = true
password_require_symbols   = true
password_require_uppercase = true

# Admin settings
allow_admin_create_user_only = false
create_user_pool_users       = true
create_user_pool_groups      = true
user_pool_groups = [
  {
    name        = "Admins"
    description = "Admin users with full access"
    precedence  = 1
  },
  {
    name        = "Developers"
    description = "Developer group"
    precedence  = 2
  }
]

user_pool_users = [
  {
    username = "alice@example.com"
    email    = "alice@example.com"
    password = "TempPassw0rd!"
  },
  {
    username = "bob@example.com"
    email    = "bob@example.com"
    password = "TempPassw0rd!"
  }
]

user_group_memberships = [
  { user = "alice@example.com", group = "Admins" },
  { user = "bob@example.com", group = "Developers" }
]
user_pool_clients = [
  {
    name            = "arc-dev-web-client"
    generate_secret = false
    explicit_auth_flows = [
      "ALLOW_USER_SRP_AUTH",
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH"
    ]
    prevent_user_existence_errors = "ENABLED"
    access_token_validity         = 60
    id_token_validity             = 60
    refresh_token_validity        = 30
    token_validity_units = {
      access_token  = "minutes"
      id_token      = "minutes"
      refresh_token = "days"
    }
  },
  {
    name            = "arc-dev-test-client"
    generate_secret = false
    explicit_auth_flows = [
      "ALLOW_USER_SRP_AUTH",
      "ALLOW_USER_PASSWORD_AUTH",
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH"
    ]
    prevent_user_existence_errors = "ENABLED"
    access_token_validity         = 60
    id_token_validity             = 60
    refresh_token_validity        = 30
    token_validity_units = {
      access_token  = "minutes"
      id_token      = "minutes"
      refresh_token = "days"
    }
  }
]
