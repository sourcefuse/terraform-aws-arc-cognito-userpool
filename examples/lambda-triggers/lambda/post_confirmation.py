import json
import boto3

def handler(event, context):
    """
    Post Confirmation Lambda Trigger

    This function is triggered after a user confirms their account.
    You can use it to:
    - Send welcome emails
    - Create user profiles in other systems
    - Add users to groups
    - Initialize user data
    """

    user_id = event.get('userName', 'Unknown')
    user_email = event['request']['userAttributes'].get('email', '')

    print(f"Post confirmation trigger for user: {user_id}, email: {user_email}")

    try:
        # Example: Add user to a default group
        cognito_client = boto3.client('cognito-idp')
        user_pool_id = event['userPoolId']

        # Add user to 'user' group (if it exists)
        try:
            cognito_client.admin_add_user_to_group(
                UserPoolId=user_pool_id,
                Username=user_id,
                GroupName='user'
            )
            print(f"Added user {user_id} to 'user' group")
        except Exception as e:
            print(f"Could not add user to group: {str(e)}")

        # Example: Send welcome email (you would implement this)
        # send_welcome_email(user_email, user_id)

        # Example: Create user profile in external system
        # create_user_profile(user_id, user_email)

    except Exception as e:
        print(f"Error in post confirmation: {str(e)}")
        # Don't raise exception to avoid blocking user confirmation

    return event
