"""
Post Confirmation Lambda Trigger for Amazon Cognito

This function is triggered after a user confirms their account. It can be used to:
- Send welcome emails
- Create user profiles in external systems
- Initialize user data
- Log user registration events
- Set up user permissions

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
    "triggerSource": "PostConfirmation_ConfirmSignUp",
    "request": {
        "userAttributes": {
            "email": "user@example.com",
            "email_verified": "true"
        },
        "clientMetadata": {}
    },
    "response": {}
}
"""

import json
import logging
import os
import boto3
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
cognito_client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    """
    Post Confirmation Lambda trigger handler
    """
    logger.info(f"Post Confirmation trigger invoked: {json.dumps(event, default=str)}")

    try:
        # Extract user information
        user_pool_id = event['userPoolId']
        username = event['userName']
        user_attributes = event['request']['userAttributes']
        trigger_source = event['triggerSource']

        email = user_attributes.get('email', '')
        email_verified = user_attributes.get('email_verified', 'false')

        logger.info(f"Processing post-confirmation for user: {username}, email: {email}")

        # Business logic examples:

        # 1. Update user attributes with additional information
        update_user_attributes(user_pool_id, username, user_attributes)

        # 2. Send welcome notification (placeholder - would integrate with SES/SNS)
        send_welcome_notification(email, username)

        # 3. Create user profile in external system (placeholder)
        create_external_user_profile(username, user_attributes)

        # 4. Log user registration event
        log_user_registration(username, email, trigger_source)

        # 5. Initialize user preferences (placeholder)
        initialize_user_preferences(username)

        logger.info(f"Post-confirmation processing completed successfully for user: {username}")
        return event

    except Exception as e:
        logger.error(f"Post-confirmation trigger failed: {str(e)}")
        # Note: Exceptions here don't prevent user confirmation, but should be handled
        return event

def update_user_attributes(user_pool_id, username, current_attributes):
    """
    Update user attributes with additional information
    """
    try:
        # Example: Add a registration timestamp
        updates = [
            {
                'Name': 'custom:registration_date',
                'Value': datetime.utcnow().isoformat()
            }
        ]

        # Example: Set user status based on email domain
        email = current_attributes.get('email', '')
        if email:
            domain = email.split('@')[1] if '@' in email else ''
            if domain == 'company.com':
                updates.append({
                    'Name': 'custom:user_type',
                    'Value': 'employee'
                })
            else:
                updates.append({
                    'Name': 'custom:user_type',
                    'Value': 'customer'
                })

        # Note: This requires custom attributes to be defined in the user pool
        # Uncomment the following lines if you have custom attributes configured

        # cognito_client.admin_update_user_attributes(
        #     UserPoolId=user_pool_id,
        #     Username=username,
        #     UserAttributes=updates
        # )

        logger.info(f"User attributes updated for user: {username}")

    except Exception as e:
        logger.error(f"Failed to update user attributes: {str(e)}")

def send_welcome_notification(email, username):
    """
    Send welcome notification to the user
    This is a placeholder - in production, you would integrate with SES, SNS, or other services
    """
    try:
        # Placeholder for welcome email/SMS
        logger.info(f"Sending welcome notification to {email} for user {username}")

        # Example integration with SES (uncomment if SES is configured):
        # ses_client = boto3.client('ses')
        # ses_client.send_email(
        #     Source='noreply@yourcompany.com',
        #     Destination={'ToAddresses': [email]},
        #     Message={
        #         'Subject': {'Data': 'Welcome to Our Platform!'},
        #         'Body': {
        #             'Text': {'Data': f'Welcome {username}! Your account has been confirmed.'}
        #         }
        #     }
        # )

    except Exception as e:
        logger.error(f"Failed to send welcome notification: {str(e)}")

def create_external_user_profile(username, user_attributes):
    """
    Create user profile in external system
    This is a placeholder for integration with external systems
    """
    try:
        # Placeholder for external system integration
        profile_data = {
            'username': username,
            'email': user_attributes.get('email', ''),
            'name': user_attributes.get('name', ''),
            'created_at': datetime.utcnow().isoformat(),
            'source': 'cognito'
        }

        logger.info(f"Creating external user profile: {json.dumps(profile_data)}")

        # Example: Store in DynamoDB, send to API, etc.
        # dynamodb = boto3.resource('dynamodb')
        # table = dynamodb.Table('user_profiles')
        # table.put_item(Item=profile_data)

    except Exception as e:
        logger.error(f"Failed to create external user profile: {str(e)}")

def log_user_registration(username, email, trigger_source):
    """
    Log user registration event for analytics/auditing
    """
    try:
        event_data = {
            'event_type': 'user_registration',
            'username': username,
            'email': email,
            'trigger_source': trigger_source,
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown'),
            'project': os.environ.get('PROJECT_NAME', 'unknown')
        }

        logger.info(f"User registration event: {json.dumps(event_data)}")

        # Example: Send to CloudWatch, Kinesis, or external analytics service
        # cloudwatch = boto3.client('cloudwatch')
        # cloudwatch.put_metric_data(
        #     Namespace='UserRegistration',
        #     MetricData=[
        #         {
        #             'MetricName': 'NewUserRegistrations',
        #             'Value': 1,
        #             'Unit': 'Count'
        #         }
        #     ]
        # )

    except Exception as e:
        logger.error(f"Failed to log user registration: {str(e)}")

def initialize_user_preferences(username):
    """
    Initialize default user preferences
    """
    try:
        # Placeholder for user preference initialization
        default_preferences = {
            'notifications': True,
            'theme': 'light',
            'language': 'en',
            'timezone': 'UTC'
        }

        logger.info(f"Initializing preferences for user {username}: {json.dumps(default_preferences)}")

        # Example: Store preferences in DynamoDB or other storage

    except Exception as e:
        logger.error(f"Failed to initialize user preferences: {str(e)}")
