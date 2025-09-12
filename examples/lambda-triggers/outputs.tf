# ==============================================================================
# COGNITO USER POOL OUTPUTS (WITH THREAT DETECTION)
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

output "user_pool_endpoint" {
  description = "The endpoint name of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_endpoint
}

output "user_pool_issuer" {
  description = "The issuer URL for JWT tokens"
  value       = module.cognito_user_pool.user_pool_issuer
}

output "user_pool_jwks_uri" {
  description = "The JWKS URI for JWT token validation"
  value       = module.cognito_user_pool.user_pool_jwks_uri
}
