# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace for the resources"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cognito-advanced"
}

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

variable "advanced_security_mode" {
  description = "Mode for advanced security features (requires ADVANCED pricing tier)"
  type        = string
  default     = "ENFORCED"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be one of: OFF, AUDIT, ENFORCED."
  }
}

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "ON"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}
variable "software_token_mfa_configuration" {
  description = "Configuration for software token Multi-Factor Authentication (MFA) settings"
  type = object({
    enabled = bool
  })
  default = {
    enabled = true
  }
}
