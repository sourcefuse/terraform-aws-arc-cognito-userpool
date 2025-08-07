# ==============================================================================
# LAMBDA TRIGGERS EXAMPLE OUTPUTS
# ==============================================================================

output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_arn
}

output "user_pool_name" {
  description = "The name of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_name
}

output "user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = module.cognito_user_pool.user_pool_client_ids[0]
}

# Lambda function outputs
output "pre_sign_up_lambda_arn" {
  description = "ARN of the pre sign-up Lambda function"
  value       = var.enable_pre_sign_up_trigger ? aws_lambda_function.pre_sign_up[0].arn : null
}

output "post_confirmation_lambda_arn" {
  description = "ARN of the post confirmation Lambda function"
  value       = var.enable_post_confirmation_trigger ? aws_lambda_function.post_confirmation[0].arn : null
}

output "pre_authentication_lambda_arn" {
  description = "ARN of the pre authentication Lambda function"
  value       = var.enable_pre_authentication_trigger ? aws_lambda_function.pre_authentication[0].arn : null
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = local.create_lambda_functions ? aws_iam_role.lambda_execution_role[0].arn : null
}

output "enabled_triggers" {
  description = "List of enabled Lambda triggers"
  value = {
    pre_sign_up        = var.enable_pre_sign_up_trigger
    post_confirmation  = var.enable_post_confirmation_trigger
    pre_authentication = var.enable_pre_authentication_trigger
  }
}

output "summary" {
  description = "Summary of the Lambda triggers setup"
  value = {
    user_pool_id             = module.cognito_user_pool.user_pool_id
    user_pool_name           = module.cognito_user_pool.user_pool_name
    client_id                = module.cognito_user_pool.user_pool_client_ids[0]
    lambda_functions_created = local.create_lambda_functions ? 1 : 0
    enabled_triggers = {
      pre_sign_up        = var.enable_pre_sign_up_trigger
      post_confirmation  = var.enable_post_confirmation_trigger
      pre_authentication = var.enable_pre_authentication_trigger
    }
  }
}
