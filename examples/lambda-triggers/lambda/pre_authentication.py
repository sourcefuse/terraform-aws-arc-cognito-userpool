import json

def handler(event, context):
    """
    Pre Authentication Lambda Trigger

    This function is triggered before a user is authenticated.
    You can use it to:
    - Block authentication based on business logic
    - Add custom validation
    - Log authentication attempts
    - Implement custom rate limiting
    """

    user_id = event.get('userName', 'Unknown')
    user_email = event['request']['userAttributes'].get('email', '')

    print(f"Pre authentication trigger for user: {user_id}, email: {user_email}")

    # Example: Block authentication during maintenance hours
    # from datetime import datetime
    # current_hour = datetime.now().hour
    # if 2 <= current_hour <= 4:  # Maintenance window 2-4 AM
    #     raise Exception("System maintenance in progress. Please try again later.")

    # Example: Block users based on custom logic
    # if user_email.endswith('@blocked-domain.com'):
    #     raise Exception("Authentication not allowed for this domain")

    # Example: Log authentication attempt
    print(f"Authentication attempt for user: {user_id} at {context.aws_request_id}")

    return event
