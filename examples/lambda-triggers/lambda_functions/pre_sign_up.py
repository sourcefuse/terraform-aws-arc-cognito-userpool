"""
Pre Sign-up Lambda Trigger for Amazon Cognito

This function is triggered before a user signs up. It can be used to:
- Validate user attributes
- Auto-confirm users based on certain criteria
- Add custom attributes
- Prevent sign-up based on business logic

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
    "triggerSource": "PreSignUp_SignUp",
    "request": {
        "userAttributes": {
            "email": "user@example.com"
        },
        "validationData": {},
        "clientMetadata": {}
    },
    "response": {
        "autoConfirmUser": false,
        "autoVerifyEmail": false,
        "autoVerifyPhone": false
    }
}
"""

import json
import logging
import os
import re

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Pre Sign-up Lambda trigger handler
    """
    logger.info(f"Pre Sign-up trigger invoked: {json.dumps(event, default=str)}")

    try:
        # Extract user attributes
        user_attributes = event['request']['userAttributes']
        email = user_attributes.get('email', '')
        username = event['userName']
        trigger_source = event['triggerSource']

        logger.info(f"Processing sign-up for user: {username}, email: {email}")

        # Business logic examples:

        # 1. Auto-confirm users from specific domains
        if email:
            domain = email.split('@')[1] if '@' in email else ''
            trusted_domains = ['company.com', 'trusted-partner.com']

            if domain in trusted_domains:
                event['response']['autoConfirmUser'] = True
                event['response']['autoVerifyEmail'] = True
                logger.info(f"Auto-confirming user from trusted domain: {domain}")

        # 2. Validate email format (additional validation)
        if email and not is_valid_email(email):
            logger.error(f"Invalid email format: {email}")
            raise Exception("Invalid email format")

        # 3. Check for blocked domains
        blocked_domains = ['tempmail.com', 'guerrillamail.com', '10minutemail.com', 'gmail.com']
        if email:
            domain = email.split('@')[1] if '@' in email else ''
            if domain in blocked_domains:
                logger.error(f"Blocked domain detected: {domain}")
                raise Exception("Email domain not allowed")

        # 4. Validate username format
        if not is_valid_username(username):
            logger.error(f"Invalid username format: {username}")
            raise Exception("Username must be a valid email address")

        # 5. Add custom attributes based on email domain
        if email:
            domain = email.split('@')[1] if '@' in email else ''
            if domain == 'company.com':
                # This would require custom attributes to be defined in the user pool
                logger.info("User from company domain - could add custom attributes")

        logger.info(f"Pre sign-up processing completed successfully for user: {username}")
        return event

    except Exception as e:
        logger.error(f"Pre sign-up trigger failed: {str(e)}")
        # Raising an exception will prevent the user from signing up
        raise e

def is_valid_email(email):
    """
    Validate email format using regex
    """
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def is_valid_username(username):
    """
    Validate username format (in this case, must be an email)
    """
    return is_valid_email(username)
