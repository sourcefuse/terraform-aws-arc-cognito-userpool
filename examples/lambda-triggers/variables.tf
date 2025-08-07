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
  default     = "cognito-lambda"
}

# ==============================================================================
# LAMBDA TRIGGERS CONFIGURATION
# ==============================================================================

variable "enable_pre_sign_up_trigger" {
  description = "Whether to enable pre sign-up Lambda trigger"
  type        = bool
  default     = true
}

variable "enable_post_confirmation_trigger" {
  description = "Whether to enable post confirmation Lambda trigger"
  type        = bool
  default     = true
}

variable "enable_pre_authentication_trigger" {
  description = "Whether to enable pre authentication Lambda trigger"
  type        = bool
  default     = false
}
