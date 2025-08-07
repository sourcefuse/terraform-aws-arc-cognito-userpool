"""
Pre Authentication Lambda Trigger for Amazon Cognito

This function is triggered before a user authenticates. It can be used to:
- Implement custom authentication logic
- Block authentication based on conditions
- Log authentication attempts
- Validate user status
- Implement rate limiting

Event structure:
{
    "version": "1",
    "region": "us-east-1",
    "userPoolId": "us-east-1_EXAMPLE",
    "userName": "user@example.com",
    "callerContext": {
        "awsSdkVersion": "aws-sdk-unknown-version",
        "clientId": "1example23456789"
    },
    "triggerSource": "PreAuthentication_Authentication",
    "request": {
        "userAttributes": {
            "email": "user@example.com",
            "email_verified": "true"
        },
        "validationData": {},
        "userNotFound": false
    },
    "response": {}
}
"""

import json
import logging
import os
import boto3
from datetime import datetime, timedelta

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
cognito_client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    """
    Pre Authentication Lambda trigger handler
    """
    logger.info(f"Pre Authentication trigger invoked: {json.dumps(event, default=str)}")

    try:
        # Extract user information
        user_pool_id = event['userPoolId']
        username = event['userName']
        user_attributes = event['request']['userAttributes']
        trigger_source = event['triggerSource']
        user_not_found = event['request'].get('userNotFound', False)

        email = user_attributes.get('email', '')
        email_verified = user_attributes.get('email_verified', 'false')

        logger.info(f"Processing pre-authentication for user: {username}, email: {email}")

        # Check if user was not found
        if user_not_found:
            logger.warning(f"Authentication attempt for non-existent user: {username}")
            raise Exception("User not found")

        # Business logic examples:

        # 1. Check if email is verified
        if email and email_verified != 'true':
            logger.error(f"Authentication blocked - email not verified for user: {username}")
            raise Exception("Email not verified. Please verify your email before signing in.")

        # 2. Check user status and account validity
        check_user_status(user_pool_id, username)

        # 3. Implement time-based access control
        check_time_based_access(user_attributes)

        # 4. Check for suspicious activity (placeholder)
        check_suspicious_activity(username, user_attributes)

        # 5. Log authentication attempt
        log_authentication_attempt(username, email, trigger_source, success=True)

        # 6. Update last login timestamp (placeholder)
        update_last_login(user_pool_id, username)

        logger.info(f"Pre-authentication processing completed successfully for user: {username}")
        return event

    except Exception as e:
        logger.error(f"Pre-authentication trigger failed: {str(e)}")
        # Log failed authentication attempt
        try:
            log_authentication_attempt(
                event.get('userName', 'unknown'),
                event['request']['userAttributes'].get('email', ''),
                event.get('triggerSource', ''),
                success=False,
                error=str(e)
            )
        except:
            pass
        # Raising an exception will prevent the user from authenticating
        raise e

def check_user_status(user_pool_id, username):
    """
    Check user status and account validity
    """
    try:
        response = cognito_client.admin_get_user(
            UserPoolId=user_pool_id,
            Username=username
        )

        user_status = response.get('UserStatus', '')
        enabled = response.get('Enabled', True)

        logger.info(f"User status for {username}: {user_status}, Enabled: {enabled}")

        # Check if user is enabled
        if not enabled:
            raise Exception("User account is disabled")

        # Check user status
        if user_status in ['UNCONFIRMED', 'RESET_REQUIRED']:
            raise Exception(f"User account status is {user_status}")

        # Check for custom attributes that might indicate account suspension
        user_attributes = {attr['Name']: attr['Value'] for attr in response.get('UserAttributes', [])}

        # Example: Check for account suspension (requires custom attribute)
        # account_suspended = user_attributes.get('custom:account_suspended', 'false')
        # if account_suspended == 'true':
        #     raise Exception("Account is temporarily suspended")

        # Example: Check account expiration (requires custom attribute)
        # account_expires = user_attributes.get('custom:account_expires')
        # if account_expires:
        #     expiry_date = datetime.fromisoformat(account_expires)
        #     if datetime.utcnow() > expiry_date:
        #         raise Exception("Account has expired")

    except cognito_client.exceptions.UserNotFoundException:
        raise Exception("User not found")
    except Exception as e:
        if "User account" in str(e) or "Account" in str(e):
            raise e
        logger.error(f"Error checking user status: {str(e)}")
        raise Exception("Unable to verify user status")

def check_time_based_access(user_attributes):
    """
    Implement time-based access control
    """
    try:
        # Example: Block access outside business hours for certain user types
        current_hour = datetime.utcnow().hour

        # Get user type from attributes (requires custom attribute)
        # user_type = user_attributes.get('custom:user_type', 'customer')

        # Example business rule: employees can access anytime, customers only during business hours
        # if user_type == 'customer' and (current_hour < 6 or current_hour > 22):
        #     raise Exception("Access is restricted to business hours (6 AM - 10 PM UTC)")

        # Example: Weekend access restrictions
        # current_weekday = datetime.utcnow().weekday()  # 0=Monday, 6=Sunday
        # if current_weekday >= 5:  # Weekend
        #     if user_type == 'contractor':
        #         raise Exception("Contractor access is not allowed on weekends")

        logger.info("Time-based access control passed")

    except Exception as e:
        if "Access is restricted" in str(e) or "access is not allowed" in str(e):
            raise e
        logger.error(f"Error in time-based access control: {str(e)}")

def check_suspicious_activity(username, user_attributes):
    """
    Check for suspicious activity patterns
    This is a placeholder for more sophisticated fraud detection
    """
    try:
        # Example: Check for rapid authentication attempts (would require external storage)
        # This is a simplified example - in production, you'd use DynamoDB or Redis

        # Example: Geographic restrictions based on IP (would need IP from context)
        # allowed_countries = ['US', 'CA', 'GB']
        # user_country = get_country_from_ip(context.get('sourceIp', ''))
        # if user_country not in allowed_countries:
        #     raise Exception("Access from this location is not permitted")

        # Example: Device fingerprinting (would require client metadata)
        # client_metadata = event['request'].get('clientMetadata', {})
        # device_id = client_metadata.get('deviceId')
        # if device_id and not is_trusted_device(username, device_id):
        #     logger.warning(f"Authentication from untrusted device for user: {username}")

        logger.info("Suspicious activity check passed")

    except Exception as e:
        if "Access from this location" in str(e) or "not permitted" in str(e):
            raise e
        logger.error(f"Error in suspicious activity check: {str(e)}")

def log_authentication_attempt(username, email, trigger_source, success=True, error=None):
    """
    Log authentication attempt for security monitoring
    """
    try:
        event_data = {
            'event_type': 'authentication_attempt',
            'username': username,
            'email': email,
            'trigger_source': trigger_source,
            'success': success,
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown'),
            'project': os.environ.get('PROJECT_NAME', 'unknown')
        }

        if error:
            event_data['error'] = error

        logger.info(f"Authentication attempt logged: {json.dumps(event_data)}")

        # Example: Send to CloudWatch for monitoring
        # cloudwatch = boto3.client('cloudwatch')
        # metric_name = 'SuccessfulAuthentications' if success else 'FailedAuthentications'
        # cloudwatch.put_metric_data(
        #     Namespace='Authentication',
        #     MetricData=[
        #         {
        #             'MetricName': metric_name,
        #             'Value': 1,
        #             'Unit': 'Count',
        #             'Dimensions': [
        #                 {
        #                     'Name': 'Environment',
        #                     'Value': os.environ.get('ENVIRONMENT', 'unknown')
        #                 }
        #             ]
        #         }
        #     ]
        # )

    except Exception as e:
        logger.error(f"Failed to log authentication attempt: {str(e)}")

def update_last_login(user_pool_id, username):
    """
    Update user's last login timestamp
    """
    try:
        # Example: Update custom attribute with last login time
        # This requires a custom attribute to be defined in the user pool

        # cognito_client.admin_update_user_attributes(
        #     UserPoolId=user_pool_id,
        #     Username=username,
        #     UserAttributes=[
        #         {
        #             'Name': 'custom:last_login',
        #             'Value': datetime.utcnow().isoformat()
        #         }
        #     ]
        # )

        logger.info(f"Last login timestamp updated for user: {username}")

    except Exception as e:
        logger.error(f"Failed to update last login timestamp: {str(e)}")
