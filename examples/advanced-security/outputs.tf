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

# ------------------------------------------------------------------------------
# Threat Detection / Advanced Security Outputs
# ------------------------------------------------------------------------------

# output "threat_detection_config" {
#   description = "Threat detection / advanced security configuration applied to the User Pool"
#   value       = var.threat_detection_config
# }

# output "security_features" {
#   description = "Summary of threat detection and advanced security features enabled"
#   value = {
#     standard_auth_mode   = try(var.threat_detection_config.standard_auth_enforcement_mode, null)
#     custom_auth_mode     = try(var.threat_detection_config.custom_auth_enforcement_mode, null)
#     compromised_creds    = try(var.threat_detection_config.compromised_credentials_detection, null)
#     adaptive_auth        = try(var.threat_detection_config.adaptive_authentication, null)
#     ip_exceptions        = try(var.threat_detection_config.ip_address_exceptions, null)
#   }
# }

# output "summary" {
#   description = "Summary of the Cognito User Pool with security posture"
#   value = {
#     user_pool_id   = module.cognito_user_pool.user_pool_id
#     user_pool_name = module.cognito_user_pool.user_pool_name
#     client_id      = module.cognito_user_pool.user_pool_client_ids[0]

#     threat_detection = {
#       standard_auth_mode = try(var.threat_detection_config.standard_auth_enforcement_mode, null)
#       custom_auth_mode   = try(var.threat_detection_config.custom_auth_enforcement_mode, null)
#       compromised_creds  = var.threat_detection_config.compromised_credentials_detection != null
#       adaptive_auth      = var.threat_detection_config.adaptive_authentication != null
#       ip_exceptions      = length(try(var.threat_detection_config.ip_address_exceptions.always_allow, [])) > 0 || length(try(var.threat_detection_config.ip_address_exceptions.always_block, [])) > 0
#     }
#   }
# }
