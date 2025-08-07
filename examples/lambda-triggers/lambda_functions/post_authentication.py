"""
Post Authentication Lambda Trigger for Amazon Cognito

This function is triggered after a user successfully authenticates. It can be used to:
- Log successful authentication events
- Update user activity tracking
- Trigger post-login workflows
- Send notifications
- Update external systems

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
    "triggerSource": "PostAuthentication_Authentication",
    "request": {
        "userAttributes": {
            "email": "user@example.com",
            "email_verified": "true"
        },
        "newDeviceUsed": false,
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
    Post Authentication Lambda trigger handler
    """
    logger.info(f"Post Authentication trigger invoked: {json.dumps(event, default=str)}")

    try:
        # Extract user information
        user_pool_id = event['userPoolId']
        username = event['userName']
        user_attributes = event['request']['userAttributes']
        trigger_source = event['triggerSource']
        new_device_used = event['request'].get('newDeviceUsed', False)
        client_metadata = event['request'].get('clientMetadata', {})

        email = user_attributes.get('email', '')

        logger.info(f"Processing post-authentication for user: {username}, email: {email}")

        # Business logic examples:

        # 1. Update user's last login information
        update_last_login_info(user_pool_id, username, new_device_used)

        # 2. Log successful authentication
        log_successful_authentication(username, email, trigger_source, new_device_used)

        # 3. Handle new device detection
        if new_device_used:
            handle_new_device_login(username, email, client_metadata)

        # 4. Update user activity metrics
        update_user_activity_metrics(username, user_attributes)

        # 5. Trigger post-login workflows
        trigger_post_login_workflows(username, user_attributes, client_metadata)

        # 6. Send login notifications if configured
        send_login_notifications(username, email, new_device_used)

        # 7. Update external systems
        update_external_systems(username, user_attributes)

        logger.info(f"Post-authentication processing completed successfully for user: {username}")
        return event

    except Exception as e:
        logger.error(f"Post-authentication trigger failed: {str(e)}")
        # Note: Exceptions here don't prevent authentication, but should be handled
        return event

def update_last_login_info(user_pool_id, username, new_device_used):
    """
    Update user's last login information
    """
    try:
        current_time = datetime.utcnow().isoformat()

        # Prepare attributes to update
        attributes_to_update = [
            {
                'Name': 'custom:last_login',
                'Value': current_time
            }
        ]

        if new_device_used:
            attributes_to_update.append({
                'Name': 'custom:last_new_device_login',
                'Value': current_time
            })

        # Note: This requires custom attributes to be defined in the user pool
        # Uncomment the following lines if you have custom attributes configured

        # cognito_client.admin_update_user_attributes(
        #     UserPoolId=user_pool_id,
        #     Username=username,
        #     UserAttributes=attributes_to_update
        # )

        logger.info(f"Last login info updated for user: {username}")

    except Exception as e:
        logger.error(f"Failed to update last login info: {str(e)}")

def log_successful_authentication(username, email, trigger_source, new_device_used):
    """
    Log successful authentication event
    """
    try:
        event_data = {
            'event_type': 'successful_authentication',
            'username': username,
            'email': email,
            'trigger_source': trigger_source,
            'new_device_used': new_device_used,
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown'),
            'project': os.environ.get('PROJECT_NAME', 'unknown')
        }

        logger.info(f"Successful authentication logged: {json.dumps(event_data)}")

        # Example: Send to CloudWatch for monitoring
        # cloudwatch = boto3.client('cloudwatch')
        # cloudwatch.put_metric_data(
        #     Namespace='Authentication',
        #     MetricData=[
        #         {
        #             'MetricName': 'SuccessfulLogins',
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

        # Example: Send to Kinesis for real-time processing
        # kinesis = boto3.client('kinesis')
        # kinesis.put_record(
        #     StreamName='authentication-events',
        #     Data=json.dumps(event_data),
        #     PartitionKey=username
        # )

    except Exception as e:
        logger.error(f"Failed to log successful authentication: {str(e)}")

def handle_new_device_login(username, email, client_metadata):
    """
    Handle login from a new device
    """
    try:
        logger.info(f"New device login detected for user: {username}")

        # Extract device information from client metadata
        device_info = {
            'user_agent': client_metadata.get('userAgent', 'unknown'),
            'device_id': client_metadata.get('deviceId', 'unknown'),
            'platform': client_metadata.get('platform', 'unknown'),
            'timestamp': datetime.utcnow().isoformat()
        }

        logger.info(f"Device info: {json.dumps(device_info)}")

        # Example: Store device information
        # dynamodb = boto3.resource('dynamodb')
        # table = dynamodb.Table('user_devices')
        # table.put_item(
        #     Item={
        #         'username': username,
        #         'device_id': device_info['device_id'],
        #         'user_agent': device_info['user_agent'],
        #         'platform': device_info['platform'],
        #         'first_seen': device_info['timestamp'],
        #         'last_seen': device_info['timestamp']
        #     }
        # )

        # Example: Send security notification
        send_new_device_notification(username, email, device_info)

    except Exception as e:
        logger.error(f"Failed to handle new device login: {str(e)}")

def send_new_device_notification(username, email, device_info):
    """
    Send notification about new device login
    """
    try:
        # Example: Send email notification via SES
        # ses = boto3.client('ses')
        # ses.send_email(
        #     Source='security@yourcompany.com',
        #     Destination={'ToAddresses': [email]},
        #     Message={
        #         'Subject': {'Data': 'New Device Login Detected'},
        #         'Body': {
        #             'Text': {
        #                 'Data': f'Hello {username},\n\nWe detected a login from a new device:\n\nDevice: {device_info["platform"]}\nTime: {device_info["timestamp"]}\n\nIf this wasn\'t you, please contact support immediately.'
        #             }
        #         }
        #     }
        # )

        logger.info(f"New device notification sent to {email}")

    except Exception as e:
        logger.error(f"Failed to send new device notification: {str(e)}")

def update_user_activity_metrics(username, user_attributes):
    """
    Update user activity metrics
    """
    try:
        # Example: Increment login count
        # This could be stored in DynamoDB or sent to analytics service

        activity_data = {
            'username': username,
            'login_timestamp': datetime.utcnow().isoformat(),
            'user_type': user_attributes.get('custom:user_type', 'unknown'),
            'email_domain': user_attributes.get('email', '').split('@')[1] if '@' in user_attributes.get('email', '') else 'unknown'
        }

        logger.info(f"User activity metrics: {json.dumps(activity_data)}")

        # Example: Store in DynamoDB
        # dynamodb = boto3.resource('dynamodb')
        # table = dynamodb.Table('user_activity')
        # table.put_item(Item=activity_data)

        # Example: Send to analytics service
        # analytics_client = boto3.client('personalize-events')
        # analytics_client.put_events(
        #     trackingId='your-tracking-id',
        #     userId=username,
        #     sessionId=f"session-{datetime.utcnow().timestamp()}",
        #     eventList=[
        #         {
        #             'eventType': 'login',
        #             'sentAt': datetime.utcnow(),
        #             'properties': json.dumps(activity_data)
        #         }
        #     ]
        # )

    except Exception as e:
        logger.error(f"Failed to update user activity metrics: {str(e)}")

def trigger_post_login_workflows(username, user_attributes, client_metadata):
    """
    Trigger post-login workflows
    """
    try:
        # Example: Trigger different workflows based on user type
        user_type = user_attributes.get('custom:user_type', 'customer')

        workflow_data = {
            'username': username,
            'user_type': user_type,
            'email': user_attributes.get('email', ''),
            'login_timestamp': datetime.utcnow().isoformat(),
            'client_info': client_metadata
        }

        logger.info(f"Triggering post-login workflows for user type: {user_type}")

        # Example: Send to SQS for async processing
        # sqs = boto3.client('sqs')
        # queue_url = f"https://sqs.{os.environ.get('AWS_REGION')}.amazonaws.com/{os.environ.get('ACCOUNT_ID')}/post-login-workflows"
        # sqs.send_message(
        #     QueueUrl=queue_url,
        #     MessageBody=json.dumps(workflow_data),
        #     MessageAttributes={
        #         'user_type': {
        #             'StringValue': user_type,
        #             'DataType': 'String'
        #         }
        #     }
        # )

        # Example: Trigger Step Functions workflow
        # stepfunctions = boto3.client('stepfunctions')
        # stepfunctions.start_execution(
        #     stateMachineArn='arn:aws:states:region:account:stateMachine:post-login-workflow',
        #     input=json.dumps(workflow_data)
        # )

    except Exception as e:
        logger.error(f"Failed to trigger post-login workflows: {str(e)}")

def send_login_notifications(username, email, new_device_used):
    """
    Send login notifications if configured
    """
    try:
        # Example: Send login notification based on user preferences
        # This would typically check user preferences stored elsewhere

        notification_data = {
            'username': username,
            'email': email,
            'login_time': datetime.utcnow().isoformat(),
            'new_device': new_device_used
        }

        # Example: Send to SNS topic for notification processing
        # sns = boto3.client('sns')
        # sns.publish(
        #     TopicArn='arn:aws:sns:region:account:login-notifications',
        #     Message=json.dumps(notification_data),
        #     Subject='User Login Notification'
        # )

        logger.info(f"Login notification processed for user: {username}")

    except Exception as e:
        logger.error(f"Failed to send login notifications: {str(e)}")

def update_external_systems(username, user_attributes):
    """
    Update external systems with login information
    """
    try:
        # Example: Update CRM system with last login
        # Example: Update analytics platform
        # Example: Update audit system

        external_update_data = {
            'username': username,
            'email': user_attributes.get('email', ''),
            'last_login': datetime.utcnow().isoformat(),
            'user_status': 'active'
        }

        logger.info(f"External systems update data: {json.dumps(external_update_data)}")

        # Example: Call external API
        # import requests
        # requests.post(
        #     'https://api.yourcompany.com/users/login-update',
        #     json=external_update_data,
        #     headers={'Authorization': 'Bearer your-api-token'}
        # )

    except Exception as e:
        logger.error(f"Failed to update external systems: {str(e)}")
