# Advanced Security Cognito User Pool Example

⚠️ **IMPORTANT**: This example requires the **ADVANCED pricing tier** in your AWS account.

## Features Demonstrated

- **Advanced Security Mode**: `ENFORCED` - Blocks suspicious activity automatically
- **Enhanced Password Policy**: 12+ characters with complexity requirements
- **Device Tracking**: Remember trusted devices and challenge new ones
- **Shorter Token Validity**: Enhanced security with 30-minute tokens
- **MFA Support**: Optional multi-factor authentication

## Prerequisites

1. **Enable ADVANCED pricing tier** in your AWS Cognito console
2. **Understand the costs** - Advanced features have additional per-MAU charges
3. **Review security policies** with your security team

## Advanced Security Features

### Risk-Based Authentication
- Automatically detects and blocks suspicious sign-in attempts
- Analyzes device, location, and behavioral patterns
- Provides risk scores for authentication attempts

### Compromised Credential Detection
- Checks passwords against known compromised credential databases
- Automatically blocks or challenges users with compromised credentials
- Provides security event logging

### Enhanced Monitoring
- Detailed security event logs in CloudWatch
- Risk assessment metrics
- Authentication attempt analysis

## Usage

```bash
# Initialize
terraform init

# Plan (review the advanced features and costs)
terraform plan

# Apply (only if you have ADVANCED tier enabled)
terraform apply
```

## Configuration Options

### Security Modes

| Mode | Description | Cost Impact |
|------|-------------|-------------|
| `OFF` | No advanced security | No additional cost |
| `AUDIT` | Log security events only | ADVANCED tier required |
| `ENFORCED` | Block suspicious activity | ADVANCED tier required |

### MFA Options

```hcl
# Disable MFA
mfa_configuration = "OFF"

# Optional MFA (users can choose)
mfa_configuration = "OPTIONAL"

# Required MFA (all users must enable)
mfa_configuration = "ON"
```

## Testing Advanced Features

After deployment, test the security features:

### 1. Normal Authentication
```bash
USER_POOL_ID=$(terraform output -raw user_pool_id)
CLIENT_ID=$(terraform output -raw user_pool_client_id)

# Create a test user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser \
  --user-attributes Name=email,Value=test@example.com \
  --temporary-password TempPass123! \
  --message-action SUPPRESS
```

### 2. Test Risk Detection
- Try logging in from different IP addresses
- Use different devices/browsers
- Monitor CloudWatch logs for risk assessments

### 3. Test Device Tracking
- Log in from a new device
- Check if device challenge is triggered
- Mark device as trusted and test again

## Monitoring

Monitor advanced security events:

### CloudWatch Logs
```bash
# View security events
aws logs describe-log-groups --log-group-name-prefix "/aws/cognito"
```

### Security Metrics
- Authentication success/failure rates
- Risk score distributions
- Blocked authentication attempts
- Device registration patterns

## Cost Optimization

### Development/Testing
- Use `basic-user-pool` example instead
- Only enable ADVANCED tier for production testing
- Monitor usage in AWS Cost Explorer

### Production
- Start with `AUDIT` mode to understand impact
- Gradually move to `ENFORCED` mode
- Set up cost alerts for unexpected usage

## Troubleshooting

### Common Issues

1. **"TierChangeNotAllowedException"**
   - Solution: Enable ADVANCED pricing tier in Cognito console

2. **High costs**
   - Check per-MAU charges for advanced security
   - Consider using `AUDIT` mode initially

3. **Users blocked unexpectedly**
   - Review risk thresholds
   - Check CloudWatch logs for risk reasons
   - Consider user education about trusted devices

## Security Best Practices

1. **Monitor regularly** - Set up CloudWatch alarms
2. **User education** - Inform users about device challenges
3. **Gradual rollout** - Start with AUDIT mode
4. **Cost monitoring** - Set up billing alerts
5. **Incident response** - Plan for handling blocked legitimate users

## Related Examples

- **[basic-user-pool](../basic-user-pool/)** - Simple setup without advanced features
- **[hosted-ui-app-client](../hosted-ui-app-client/)** - Web application integration
- **[federated-identity-provider](../federated-identity-provider/)** - Social login integration

This example provides enterprise-grade security features for applications requiring the highest level of protection.
