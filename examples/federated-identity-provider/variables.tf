# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ==============================================================================
# HOSTED UI CONFIGURATION
# ==============================================================================

variable "create_hosted_ui_domain" {
  description = "Whether to create a hosted UI domain"
  type        = bool
  default     = true
}

variable "hosted_ui_domain_prefix" {
  description = "Domain prefix for the hosted UI (if null, will use project-environment-auth)"
  type        = string
  default     = null
}

variable "callback_urls" {
  description = "List of allowed callback URLs for the app client"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the app client"
  type        = list(string)
  default     = ["http://localhost:3000/logout"]
}

variable "default_redirect_uri" {
  description = "Default redirect URI for the app client"
  type        = string
  default     = "http://localhost:3000/callback"
}

# ==============================================================================
# OAUTH CONFIGURATION
# ==============================================================================

variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = ["code", "implicit"]

  validation {
    condition = alltrue([
      for flow in var.allowed_oauth_flows : contains(["code", "implicit", "client_credentials"], flow)
    ])
    error_message = "Allowed OAuth flows must be one of: code, implicit, client_credentials."
  }
}

variable "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  type        = list(string)
  default     = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
}

# ==============================================================================
# CLIENT CONFIGURATION
# ==============================================================================

variable "generate_client_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = false
}

variable "explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

variable "read_attributes" {
  description = "List of user pool attributes the app client can read"
  type        = list(string)
  default = [
    "email",
    "email_verified",
    "name",
    "family_name",
    "given_name",
    "preferred_username",
    "picture"
  ]
}

variable "write_attributes" {
  description = "List of user pool attributes the app client can write"
  type        = list(string)
  default = [
    "email",
    "name",
    "family_name",
    "given_name",
    "preferred_username",
    "picture"
  ]
}

# ==============================================================================
# TOKEN CONFIGURATION
# ==============================================================================

variable "access_token_validity" {
  description = "Time limit, in minutes, after which the access token is no longer valid"
  type        = number
  default     = 60

  validation {
    condition     = var.access_token_validity >= 5 && var.access_token_validity <= 1440
    error_message = "Access token validity must be between 5 minutes and 1 day (1440 minutes)."
  }
}

variable "id_token_validity" {
  description = "Time limit, in minutes, after which the ID token is no longer valid"
  type        = number
  default     = 60

  validation {
    condition     = var.id_token_validity >= 5 && var.id_token_validity <= 1440
    error_message = "ID token validity must be between 5 minutes and 1 day (1440 minutes)."
  }
}

variable "refresh_token_validity" {
  description = "Time limit, in days, after which the refresh token is no longer valid"
  type        = number
  default     = 30

  validation {
    condition     = var.refresh_token_validity >= 1 && var.refresh_token_validity <= 3650
    error_message = "Refresh token validity must be between 1 and 3650 days."
  }
}

# ==============================================================================
# GOOGLE IDENTITY PROVIDER
# ==============================================================================

variable "enable_google_provider" {
  description = "Whether to enable Google as an identity provider"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth 2.0 client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_scopes" {
  description = "List of Google OAuth scopes to request"
  type        = list(string)
  default     = ["profile", "email", "openid"]
}

variable "google_attribute_mapping" {
  description = "Mapping of Google attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "email"
    family_name        = "family_name"
    given_name         = "given_name"
    name               = "name"
    picture            = "picture"
    preferred_username = "sub"
    username           = "sub"
  }
}

# ==============================================================================
# FACEBOOK IDENTITY PROVIDER
# ==============================================================================

variable "enable_facebook_provider" {
  description = "Whether to enable Facebook as an identity provider"
  type        = bool
  default     = false
}

variable "facebook_app_id" {
  description = "Facebook App ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "facebook_app_secret" {
  description = "Facebook App Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "facebook_scopes" {
  description = "List of Facebook permissions to request"
  type        = list(string)
  default     = ["public_profile", "email"]
}

variable "facebook_attribute_mapping" {
  description = "Mapping of Facebook attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "email"
    family_name        = "last_name"
    given_name         = "first_name"
    name               = "name"
    picture            = "picture"
    preferred_username = "id"
    username           = "id"
  }
}

# ==============================================================================
# APPLE IDENTITY PROVIDER
# ==============================================================================

variable "enable_apple_provider" {
  description = "Whether to enable Apple as an identity provider"
  type        = bool
  default     = false
}

variable "apple_services_id" {
  description = "Apple Services ID (Client ID)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "apple_team_id" {
  description = "Apple Team ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "apple_key_id" {
  description = "Apple Key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "apple_private_key" {
  description = "Apple Private Key (PEM format)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "apple_scopes" {
  description = "List of Apple scopes to request"
  type        = list(string)
  default     = ["name", "email"]
}

variable "apple_attribute_mapping" {
  description = "Mapping of Apple attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "email"
    family_name        = "lastName"
    given_name         = "firstName"
    name               = "name"
    preferred_username = "sub"
    username           = "sub"
  }
}

# ==============================================================================
# AMAZON IDENTITY PROVIDER
# ==============================================================================

variable "enable_amazon_provider" {
  description = "Whether to enable Amazon as an identity provider"
  type        = bool
  default     = false
}

variable "amazon_client_id" {
  description = "Amazon OAuth 2.0 client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "amazon_client_secret" {
  description = "Amazon OAuth 2.0 client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "amazon_scopes" {
  description = "List of Amazon OAuth scopes to request"
  type        = list(string)
  default     = ["profile"]
}

variable "amazon_attribute_mapping" {
  description = "Mapping of Amazon attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "email"
    name               = "name"
    preferred_username = "user_id"
    username           = "user_id"
  }
}

# ==============================================================================
# SAML IDENTITY PROVIDER
# ==============================================================================

variable "enable_saml_provider" {
  description = "Whether to enable SAML as an identity provider"
  type        = bool
  default     = false
}

variable "saml_provider_name" {
  description = "Name for the SAML identity provider"
  type        = string
  default     = "SAML"
}

variable "saml_metadata_url" {
  description = "URL to the SAML metadata document"
  type        = string
  default     = ""
}

variable "saml_attribute_mapping" {
  description = "Mapping of SAML attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    family_name        = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
    given_name         = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    name               = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    preferred_username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    username           = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  }
}

variable "saml_idp_identifiers" {
  description = "List of SAML IdP identifiers"
  type        = list(string)
  default     = []
}

# ==============================================================================
# OIDC IDENTITY PROVIDER
# ==============================================================================

variable "enable_oidc_provider" {
  description = "Whether to enable OIDC as an identity provider"
  type        = bool
  default     = false
}

variable "oidc_provider_name" {
  description = "Name for the OIDC identity provider"
  type        = string
  default     = "OIDC"
}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
  default     = ""
}

variable "oidc_scopes" {
  description = "List of OIDC scopes to request"
  type        = list(string)
  default     = ["openid", "profile", "email"]
}

variable "oidc_attribute_mapping" {
  description = "Mapping of OIDC attributes to Cognito attributes"
  type        = map(string)
  default = {
    email              = "email"
    family_name        = "family_name"
    given_name         = "given_name"
    name               = "name"
    picture            = "picture"
    preferred_username = "preferred_username"
    username           = "sub"
  }
}

# ==============================================================================
# PASSWORD POLICY CONFIGURATION (for Cognito native users)
# ==============================================================================

variable "password_minimum_length" {
  description = "Minimum length of the password policy"
  type        = number
  default     = 8

  validation {
    condition     = var.password_minimum_length >= 6 && var.password_minimum_length <= 99
    error_message = "Password minimum length must be between 6 and 99 characters."
  }
}

variable "password_require_lowercase" {
  description = "Whether to require lowercase letters in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether to require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether to require symbols in password"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether to require uppercase letters in password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid"
  type        = number
  default     = 7

  validation {
    condition     = var.temporary_password_validity_days >= 0 && var.temporary_password_validity_days <= 365
    error_message = "Temporary password validity days must be between 0 and 365."
  }
}

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

variable "advanced_security_mode" {
  description = "Mode for advanced security features"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be one of: OFF, AUDIT, ENFORCED."
  }
}

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "user_pool_tier" {
  description = "The user pool feature plan, or tier"
  type        = string
  default     = "PLUS"

  validation {
    condition     = contains(["LITE", "ESSENTIALS", "PLUS"], var.user_pool_tier)
    error_message = "User pool tier must be one of: LITE, ESSENTIALS, PLUS."
  }
}
