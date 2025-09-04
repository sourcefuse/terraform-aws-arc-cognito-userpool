import json

def handler(event, context):
    """
    Pre Sign-up Lambda Trigger

    This function is triggered before a user is created in Cognito.
    You can use it to:
    - Validate user attributes
    - Auto-confirm users
    - Add custom attributes
    - Block sign-ups based on business logic
    """

    print(f"Pre sign-up trigger for user: {event.get('userName', 'Unknown')}")

    # Auto-confirm users (skip email verification)
    # Uncomment the lines below to auto-confirm users
    # event['response']['autoConfirmUser'] = True
    # event['response']['autoVerifyEmail'] = True

    # Example: Block users with certain email domains
    user_email = event['request']['userAttributes'].get('email', '')
    blocked_domains = ['spam.com', 'blocked.com', 'gmail.com']

    if any(domain in user_email for domain in blocked_domains):
        raise ValueError("Email domain not allowed")

    # Example: Add custom attributes
    # event['response']['userAttributes'] = {
    #     'custom:signup_source': 'web',
    #     'custom:signup_date': str(datetime.now())
    # }

    return event
