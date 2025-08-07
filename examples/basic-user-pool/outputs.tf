# ==============================================================================
# USER POOL OUTPUTS
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

output "user_pool_endpoint" {
  description = "The endpoint name of the Cognito User Pool"
  value       = module.cognito_user_pool.user_pool_endpoint
}

# ==============================================================================
# CLIENT OUTPUTS
# ==============================================================================

output "user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : null
}

output "user_pool_client_name" {
  description = "The name of the Cognito User Pool Client"
  value       = length(module.cognito_user_pool.user_pool_client_names) > 0 ? module.cognito_user_pool.user_pool_client_names[0] : null
}

# ==============================================================================
# CONVENIENCE OUTPUTS
# ==============================================================================

output "user_pool_jwks_uri" {
  description = "The JSON Web Key Set (JWKS) URI for the user pool"
  value       = module.cognito_user_pool.user_pool_jwks_uri
}

output "user_pool_issuer" {
  description = "The issuer URL for the user pool"
  value       = module.cognito_user_pool.user_pool_issuer
}

# ==============================================================================
# SUMMARY OUTPUT
# ==============================================================================

output "summary" {
  description = "Summary of the created Cognito User Pool"
  value = {
    user_pool_id   = module.cognito_user_pool.user_pool_id
    user_pool_name = module.cognito_user_pool.user_pool_name
    client_id      = length(module.cognito_user_pool.user_pool_client_ids) > 0 ? module.cognito_user_pool.user_pool_client_ids[0] : null
    region         = var.aws_region
    environment    = var.environment
    project        = var.project_name
  }
}
