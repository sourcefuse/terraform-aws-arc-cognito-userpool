# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  # Check if any lambda functions should be created
  create_lambda_functions = var.enable_pre_sign_up_trigger || var.enable_post_confirmation_trigger || var.enable_pre_authentication_trigger
}
