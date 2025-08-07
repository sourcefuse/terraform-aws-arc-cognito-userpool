# ==============================================================================
# LAMBDA TRIGGERS COGNITO USER POOL EXAMPLE
# ==============================================================================

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.2"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example = "lambda-triggers"
    Repo    = "github.com/your-org/terraform-aws-cognito-user-pool"
  }
}

# ==============================================================================
# LAMBDA FUNCTIONS FOR COGNITO TRIGGERS
# ==============================================================================

# Pre Sign-up Lambda Function
resource "aws_lambda_function" "pre_sign_up" {
  count = var.enable_pre_sign_up_trigger ? 1 : 0

  filename      = "${path.module}/lambda/pre_sign_up.zip"
  function_name = "${var.namespace}-${var.environment}-pre-sign-up"
  role          = aws_iam_role.lambda_execution_role[0].arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30

  tags = module.tags.tags
}

# Post Confirmation Lambda Function
resource "aws_lambda_function" "post_confirmation" {
  count = var.enable_post_confirmation_trigger ? 1 : 0

  filename      = "${path.module}/lambda/post_confirmation.zip"
  function_name = "${var.namespace}-${var.environment}-post-confirmation"
  role          = aws_iam_role.lambda_execution_role[0].arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30

  tags = module.tags.tags
}

# Pre Authentication Lambda Function
resource "aws_lambda_function" "pre_authentication" {
  count = var.enable_pre_authentication_trigger ? 1 : 0

  filename      = "${path.module}/lambda/pre_authentication.zip"
  function_name = "${var.namespace}-${var.environment}-pre-authentication"
  role          = aws_iam_role.lambda_execution_role[0].arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30

  tags = module.tags.tags
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  count = local.create_lambda_functions ? 1 : 0

  name = "${var.namespace}-${var.environment}-cognito-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = module.tags.tags
}

# Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count = local.create_lambda_functions ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role[0].name
}

# Lambda Permissions for Cognito
resource "aws_lambda_permission" "cognito_pre_sign_up" {
  count = var.enable_pre_sign_up_trigger ? 1 : 0

  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_sign_up[0].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.user_pool_arn
}

resource "aws_lambda_permission" "cognito_post_confirmation" {
  count = var.enable_post_confirmation_trigger ? 1 : 0

  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_confirmation[0].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.user_pool_arn
}

resource "aws_lambda_permission" "cognito_pre_authentication" {
  count = var.enable_pre_authentication_trigger ? 1 : 0

  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_authentication[0].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.user_pool_arn
}

# ==============================================================================
# COGNITO USER POOL WITH LAMBDA TRIGGERS
# ==============================================================================

module "cognito_user_pool" {
  source = "../../"

  # Basic configuration
  name = "${var.namespace}-${var.environment}-lambda-pool"

  # Authentication settings
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy = {
    minimum_length                   = 8
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

  # Lambda triggers configuration
  lambda_config = {
    pre_sign_up        = var.enable_pre_sign_up_trigger ? aws_lambda_function.pre_sign_up[0].arn : null
    post_confirmation  = var.enable_post_confirmation_trigger ? aws_lambda_function.post_confirmation[0].arn : null
    pre_authentication = var.enable_pre_authentication_trigger ? aws_lambda_function.pre_authentication[0].arn : null
  }

  # User pool clients
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

  # Security settings
  advanced_security_mode = "OFF"
  mfa_configuration      = "OFF"

  # Username configuration
  username_configuration = {
    case_sensitive = false
  }

  # Tags
  tags = module.tags.tags
}
