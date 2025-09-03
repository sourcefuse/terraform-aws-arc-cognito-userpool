aws_region     = "us-east-1"
namespace      = "arc"
environment    = "dev"
project_name   = "cognito-advanced"
user_pool_tier = "PLUS"

user_pool_add_ons = {
  advanced_security_mode = "ENFORCED"
  advanced_security_additional_flows = {
    custom_auth_mode = "AUDIT"
  }
}
account_takeover_risk_configuration = {
  notify_configuration = {
    source_arn = "arn:aws:ses:us-east-1:884360309640:identity/debash.bora@sourcefuse.com"
    from       = "debash.bora@sourcefuse.com"
    block_email = {
      html_body = "<h1>Blocked</h1>"
      text_body = "Your login was blocked"
      subject   = "Blocked login attempt"
    }
  }
  actions = {
    high_action = {
      event_action = "BLOCK"
      notify       = true
    }
    medium_action = {
      event_action = "MFA_REQUIRED"
      notify       = true
    }
    low_action = {
      event_action = "NO_ACTION"
      notify       = false
    }
  }
}
compromised_credentials_risk_configuration = {
  event_filter = ["SIGN_IN", "PASSWORD_CHANGE"]
  actions = {
    event_action = "BLOCK"
  }
}
risk_exception_configuration = {
  blocked_ip_range_list = ["10.10.10.10/32"]
}

cognito_log_delivery_config = {
  event_source         = "userNotification"
  log_destination_type = "cloudwatch"
  log_level            = "ERROR"
  log_group_name       = "arc-poc-cognito-logsv2"
}

mfa_configuration = "ON"

software_token_mfa_configuration = {
  enabled = true
}
