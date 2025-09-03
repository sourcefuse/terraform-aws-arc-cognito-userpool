# ==============================================================================
# USER POOL OUTPUTS
# ==============================================================================

output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_name" {
  description = "The name of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.name
}

output "user_pool_endpoint" {
  description = "The endpoint name of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_creation_date" {
  description = "The date the Cognito User Pool was created"
  value       = aws_cognito_user_pool.this.creation_date
}

output "user_pool_last_modified_date" {
  description = "The date the Cognito User Pool was last modified"
  value       = aws_cognito_user_pool.this.last_modified_date
}

output "user_pool_estimated_number_of_users" {
  description = "A number estimating the size of the user pool"
  value       = aws_cognito_user_pool.this.estimated_number_of_users
}

output "user_pool_custom_domain" {
  description = "The custom domain name for the user pool"
  value       = aws_cognito_user_pool.this.custom_domain
}

output "user_pool_domain" {
  description = "The domain prefix if the user pool has a domain associated with it"
  value       = aws_cognito_user_pool.this.domain
}

# ==============================================================================
# USER POOL CLIENT OUTPUTS
# ==============================================================================

# ==============================================================================
# USER POOL CLIENT OUTPUTS
# ==============================================================================

output "user_pool_client_ids" {
  description = "The IDs of the Cognito User Pool Clients"
  value       = [for c in values(aws_cognito_user_pool_client.this) : c.id]
}

output "user_pool_client_names" {
  description = "The names of the Cognito User Pool Clients"
  value       = [for c in values(aws_cognito_user_pool_client.this) : c.name]
}

output "user_pool_client_secrets" {
  description = "The client secrets of the Cognito User Pool Clients (sensitive)"
  value       = [for c in values(aws_cognito_user_pool_client.this) : c.client_secret]
  sensitive   = true
}

output "user_pool_clients" {
  description = "Map of user pool client details"
  value = {
    for k, client in aws_cognito_user_pool_client.this : k => {
      id                     = client.id
      name                   = client.name
      client_secret          = client.client_secret
      user_pool_id           = client.user_pool_id
      access_token_validity  = client.access_token_validity
      id_token_validity      = client.id_token_validity
      refresh_token_validity = client.refresh_token_validity
    }
  }
  sensitive = true
}

# ==============================================================================
# USER POOL DOMAIN OUTPUTS
# ==============================================================================

output "user_pool_domain_name" {
  description = "The domain name of the Cognito User Pool Domain"
  value       = try(aws_cognito_user_pool_domain.this[0].domain, null)
}

output "user_pool_domain_aws_account_id" {
  description = "The AWS account ID for the user pool domain"
  value       = try(aws_cognito_user_pool_domain.this[0].aws_account_id, null)
}

output "user_pool_domain_cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution for the domain"
  value       = try(aws_cognito_user_pool_domain.this[0].cloudfront_distribution_arn, null)
}

output "user_pool_domain_s3_bucket" {
  description = "The S3 bucket where the static files for this domain are stored"
  value       = try(aws_cognito_user_pool_domain.this[0].s3_bucket, null)
}

output "user_pool_domain_version" {
  description = "The app version for the domain"
  value       = try(aws_cognito_user_pool_domain.this[0].version, null)
}

# ==============================================================================
# IDENTITY PROVIDER OUTPUTS
# ==============================================================================

output "identity_provider_names" {
  description = "The names of the Cognito Identity Providers"
  value       = [for idp in values(aws_cognito_identity_provider.this) : idp.provider_name]
}

output "identity_providers" {
  description = "Map of identity provider details"
  value = {
    for k, idp in aws_cognito_identity_provider.this : k => {
      provider_name     = idp.provider_name
      provider_type     = idp.provider_type
      user_pool_id      = idp.user_pool_id
      attribute_mapping = idp.attribute_mapping
      idp_identifiers   = idp.idp_identifiers
    }
  }
}

# ==============================================================================
# USER POOL GROUP OUTPUTS
# ==============================================================================

output "user_pool_group_names" {
  description = "The names of the Cognito User Pool Groups"
  value       = [for g in values(aws_cognito_user_group.this) : g.id]
}

output "user_pool_groups" {
  description = "Map of user pool group details"
  value = {
    for k, g in aws_cognito_user_group.this : g.id => {
      name         = g.id
      description  = g.description
      precedence   = g.precedence
      role_arn     = g.role_arn
      user_pool_id = g.user_pool_id
    }
  }
}

# ==============================================================================
# RESOURCE SERVER OUTPUTS
# ==============================================================================

output "resource_server_identifiers" {
  description = "The identifiers of the Cognito Resource Servers"
  value       = [for rs in values(aws_cognito_resource_server.this) : rs.identifier]
}

output "resource_server_names" {
  description = "The names of the Cognito Resource Servers"
  value       = [for rs in values(aws_cognito_resource_server.this) : rs.name]
}

output "resource_servers" {
  description = "Map of resource server details"
  value = {
    for k, rs in aws_cognito_resource_server.this : k => {
      identifier        = rs.identifier
      name              = rs.name
      user_pool_id      = rs.user_pool_id
      scope_identifiers = rs.scope_identifiers
    }
  }
}

# ==============================================================================
# CONVENIENCE OUTPUTS
# ==============================================================================

output "user_pool_hosted_ui_url" {
  description = "The URL of the hosted UI for the user pool (if domain is configured)"
  value = try(
    "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.id}.amazoncognito.com",
    null
  )
}

output "user_pool_jwks_uri" {
  description = "The JSON Web Key Set (JWKS) URI for the user pool"
  value       = "https://cognito-idp.${data.aws_region.current.id}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/jwks.json"
}

output "user_pool_issuer" {
  description = "The issuer URL for the user pool"
  value       = "https://cognito-idp.${data.aws_region.current.id}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

# ==============================================================================
# SUMMARY OUTPUT
# ==============================================================================

output "summary" {
  description = "Summary of all created resources"
  value = {
    user_pool = {
      id       = aws_cognito_user_pool.this.id
      arn      = aws_cognito_user_pool.this.arn
      name     = aws_cognito_user_pool.this.name
      endpoint = aws_cognito_user_pool.this.endpoint
    }
    clients_count            = length(aws_cognito_user_pool_client.this)
    domain_configured        = length(aws_cognito_user_pool_domain.this) > 0
    identity_providers_count = length(aws_cognito_identity_provider.this)
    groups_count             = length(aws_cognito_user_group.this)
    resource_servers_count   = length(aws_cognito_resource_server.this)
  }
}
