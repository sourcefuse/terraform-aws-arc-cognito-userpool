# ==============================================================================
# LAMBDA TRIGGERS COGNITO USER POOL EXAMPLE
# ==============================================================================

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name

}

# ==============================================================================
# LAMBDA FUNCTIONS FOR COGNITO TRIGGERS
# ==============================================================================

# Pre Sign-up Lambda
module "pre_sign_up_lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.1"

  count = var.enable_pre_sign_up_trigger ? 1 : 0

  function_name = "${var.namespace}-${var.environment}-pre-sign-up"
  description   = "Lambda for Cognito Pre Sign-up trigger"
  handler       = "index.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda/pre_sign_up.zip"
  timeout       = 30

  tags = module.tags.tags
}

# Post Confirmation Lambda
module "post_confirmation_lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.1"

  count = var.enable_post_confirmation_trigger ? 1 : 0

  function_name = "${var.namespace}-${var.environment}-post-confirmation"
  description   = "Lambda for Cognito Post Confirmation trigger"
  handler       = "index.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda/post_confirmation.zip"
  timeout       = 30

  tags = module.tags.tags
}

# Pre Authentication Lambda
module "pre_authentication_lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.1"

  count = var.enable_pre_authentication_trigger ? 1 : 0

  function_name = "${var.namespace}-${var.environment}-pre-authentication"
  description   = "Lambda for Cognito Pre Authentication trigger"
  handler       = "index.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda/pre_authentication.zip"
  timeout       = 30

  tags = module.tags.tags
}

# ==============================================================================
# COGNITO USER POOL WITH LAMBDA TRIGGERS
# ==============================================================================

module "cognito_user_pool" {
  source = "../../"

  name = "${var.namespace}-${var.environment}-lambda-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy = {
    minimum_length                   = 8
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

  # Correctly wire Lambda triggers
  lambda_config = {
    pre_sign_up        = var.enable_pre_sign_up_trigger ? module.pre_sign_up_lambda[0].arn : null
    post_confirmation  = var.enable_post_confirmation_trigger ? module.post_confirmation_lambda[0].arn : null
    pre_authentication = var.enable_pre_authentication_trigger ? module.pre_authentication_lambda[0].arn : null
  }

  user_pool_clients = [
    {
      name            = "${var.namespace}-${var.environment}-lambda-client"
      generate_secret = false

      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
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

  mfa_configuration = "OFF"

  username_configuration = {
    case_sensitive = false
  }

  tags = module.tags.tags
}
