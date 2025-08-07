# ==============================================================================
# ADVANCED SECURITY EXAMPLE OUTPUTS
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

output "advanced_security_mode" {
  description = "The advanced security mode configured"
  value       = var.advanced_security_mode
}

output "mfa_configuration" {
  description = "The MFA configuration"
  value       = var.mfa_configuration
}

output "device_tracking_enabled" {
  description = "Whether device tracking is enabled"
  value       = true
}

output "security_features" {
  description = "Summary of security features enabled"
  value = {
    advanced_security_mode = var.advanced_security_mode
    mfa_enabled            = var.mfa_configuration != "OFF"
    device_tracking        = true
    short_token_validity   = true
    strong_password_policy = true
  }
}

output "summary" {
  description = "Summary of the advanced security setup"
  value = {
    user_pool_id   = module.cognito_user_pool.user_pool_id
    user_pool_name = module.cognito_user_pool.user_pool_name
    client_id      = module.cognito_user_pool.user_pool_client_ids[0]
    security_tier  = "ADVANCED"
    features_enabled = {
      advanced_security = var.advanced_security_mode != "OFF"
      mfa               = var.mfa_configuration != "OFF"
      device_tracking   = true
      enhanced_tokens   = true
    }
  }
}
