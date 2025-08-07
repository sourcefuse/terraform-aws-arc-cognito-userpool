"""
User Migration Lambda Trigger for Amazon Cognito

This function is triggered when a user that doesn't exist in the Cognito User Pool
tries to authenticate. It can be used to:
- Migrate users from legacy authentication systems
- Validate credentials against external systems
- Import user data during authentication
- Seamlessly transition users to Cognito

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
    "triggerSource": "UserMigration_Authentication",
    "request": {
        "password": "user-provided-password",
        "validationData": {},
        "clientMetadata": {}
    },
    "response": {
        "userAttributes": {},
        "finalUserStatus": "CONFIRMED",
        "messageAction": "SUPPRESS",
        "desiredDeliveryMediums": ["EMAIL"]
    }
}
"""

import json
import logging
import os
import boto3
import hashlib
import hmac
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    User Migration Lambda trigger handler
    """
    logger.info(f"User Migration trigger invoked: {json.dumps(event, default=str, indent=2)}")

    try:
        # Extract user information
        username = event['userName']
        password = event['request']['password']
        trigger_source = event['triggerSource']
        client_metadata = event['request'].get('clientMetadata', {})

        logger.info(f"Processing user migration for user: {username}")

        # Validate user credentials against legacy system
        user_data = validate_legacy_credentials(username, password)

        if user_data:
            # User exists in legacy system and credentials are valid
            logger.info(f"User {username} found in legacy system, migrating to Cognito")

            # Set user attributes for Cognito
            event['response']['userAttributes'] = {
                'email': user_data['email'],
                'email_verified': 'true',  # Assume email is already verified in legacy system
                'name': user_data.get('name', ''),
                'family_name': user_data.get('family_name', ''),
                'given_name': user_data.get('given_name', ''),
                # Add custom attributes if needed
                'custom:migrated_from': 'legacy_system',
                'custom:migration_date': datetime.utcnow().isoformat(),
                'custom:legacy_user_id': user_data.get('legacy_id', '')
            }

            # Set user status to CONFIRMED (skip email verification)
            event['response']['finalUserStatus'] = 'CONFIRMED'

            # Suppress welcome message since user is being migrated
            event['response']['messageAction'] = 'SUPPRESS'

            # Log successful migration
            log_user_migration(username, user_data, success=True)

            # Update legacy system to mark user as migrated (optional)
            mark_user_as_migrated(username, user_data.get('legacy_id'))

            logger.info(f"User migration completed successfully for user: {username}")

        else:
            # User not found or invalid credentials
            logger.warning(f"User {username} not found in legacy system or invalid credentials")
            # Don't set response attributes - this will cause authentication to fail
            # which is the correct behavior for invalid credentials

            # Log failed migration attempt
            log_user_migration(username, None, success=False, error="Invalid credentials or user not found")

        return event

    except Exception as e:
        logger.error(f"User migration trigger failed: {str(e)}")
        # Log failed migration attempt
        try:
            log_user_migration(event.get('userName', 'unknown'), None, success=False, error=str(e))
        except:
            pass
        # Don't set response attributes on error - authentication will fail
        return event

def validate_legacy_credentials(username, password):
    """
    Validate user credentials against legacy system
    This example uses DynamoDB, but you could integrate with any system
    """
    try:
        # Get the migration table name from environment
        table_name = os.environ.get('USER_MIGRATION_TABLE', '')
        if not table_name:
            logger.error("USER_MIGRATION_TABLE environment variable not set")
            return None

        table = dynamodb.Table(table_name)

        # Look up user in legacy system (DynamoDB in this example)
        response = table.get_item(
            Key={'username': username}
        )

        if 'Item' not in response:
            logger.info(f"User {username} not found in legacy system")
            return None

        user_item = response['Item']
        stored_password = user_item.get('password', '')

        # Validate password (this example assumes plain text, but you should use proper hashing)
        # In production, you would compare hashed passwords
        if not verify_password(password, stored_password):
            logger.warning(f"Invalid password for user {username}")
            return None

        # Return user data for migration
        return {
            'email': user_item.get('email', username),
            'name': user_item.get('name', ''),
            'family_name': extract_family_name(user_item.get('name', '')),
            'given_name': extract_given_name(user_item.get('name', '')),
            'legacy_id': user_item.get('legacy_id', username),
            'created_at': user_item.get('created_at', ''),
            'last_login': user_item.get('last_login', '')
        }

    except Exception as e:
        logger.error(f"Error validating legacy credentials: {str(e)}")
        return None

def verify_password(provided_password, stored_password):
    """
    Verify password against stored password
    This is a simplified example - in production, use proper password hashing
    """
    try:
        # Example 1: Plain text comparison (NOT RECOMMENDED for production)
        if stored_password == provided_password:
            return True

        # Example 2: Hash comparison (recommended)
        # stored_hash = stored_password
        # provided_hash = hashlib.sha256(provided_password.encode()).hexdigest()
        # return hmac.compare_digest(stored_hash, provided_hash)

        # Example 3: bcrypt comparison (best practice)
        # import bcrypt
        # return bcrypt.checkpw(provided_password.encode('utf-8'), stored_password.encode('utf-8'))

        return False

    except Exception as e:
        logger.error(f"Error verifying password: {str(e)}")
        return False

def extract_given_name(full_name):
    """
    Extract given name from full name
    """
    try:
        if not full_name:
            return ''
        parts = full_name.strip().split()
        return parts[0] if parts else ''
    except:
        return ''

def extract_family_name(full_name):
    """
    Extract family name from full name
    """
    try:
        if not full_name:
            return ''
        parts = full_name.strip().split()
        return parts[-1] if len(parts) > 1 else ''
    except:
        return ''

def log_user_migration(username, user_data, success=True, error=None):
    """
    Log user migration attempt for auditing
    """
    try:
        migration_log = {
            'event_type': 'user_migration',
            'username': username,
            'success': success,
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown'),
            'project': os.environ.get('PROJECT_NAME', 'unknown')
        }

        if user_data:
            migration_log['legacy_id'] = user_data.get('legacy_id', '')
            migration_log['email'] = user_data.get('email', '')

        if error:
            migration_log['error'] = error

        logger.info(f"User migration logged: {json.dumps(migration_log)}")

        # Example: Send to CloudWatch for monitoring
        # cloudwatch = boto3.client('cloudwatch')
        # metric_name = 'SuccessfulMigrations' if success else 'FailedMigrations'
        # cloudwatch.put_metric_data(
        #     Namespace='UserMigration',
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

        # Example: Store migration log in DynamoDB
        # log_table = dynamodb.Table('user_migration_logs')
        # log_table.put_item(Item=migration_log)

    except Exception as e:
        logger.error(f"Failed to log user migration: {str(e)}")

def mark_user_as_migrated(username, legacy_id):
    """
    Mark user as migrated in the legacy system
    This prevents duplicate migrations and can be used for cleanup
    """
    try:
        table_name = os.environ.get('USER_MIGRATION_TABLE', '')
        if not table_name:
            return

        table = dynamodb.Table(table_name)

        # Update the user record to mark as migrated
        table.update_item(
            Key={'username': username},
            UpdateExpression='SET migrated = :migrated, migration_date = :date',
            ExpressionAttributeValues={
                ':migrated': True,
                ':date': datetime.utcnow().isoformat()
            }
        )

        logger.info(f"User {username} marked as migrated in legacy system")

    except Exception as e:
        logger.error(f"Failed to mark user as migrated: {str(e)}")

def validate_external_api_credentials(username, password):
    """
    Alternative implementation: Validate credentials against external API
    """
    try:
        import requests

        # Example: Call external authentication API
        response = requests.post(
            'https://legacy-auth.yourcompany.com/validate',
            json={
                'username': username,
                'password': password
            },
            headers={
                'Authorization': 'Bearer your-api-token',
                'Content-Type': 'application/json'
            },
            timeout=10
        )

        if response.status_code == 200:
            user_data = response.json()
            return {
                'email': user_data.get('email', username),
                'name': user_data.get('full_name', ''),
                'family_name': user_data.get('last_name', ''),
                'given_name': user_data.get('first_name', ''),
                'legacy_id': user_data.get('user_id', username),
                'created_at': user_data.get('created_date', ''),
                'last_login': user_data.get('last_login_date', '')
            }
        else:
            logger.warning(f"External API returned status {response.status_code} for user {username}")
            return None

    except Exception as e:
        logger.error(f"Error validating credentials with external API: {str(e)}")
        return None

def validate_ldap_credentials(username, password):
    """
    Alternative implementation: Validate credentials against LDAP
    """
    try:
        # Example LDAP integration (requires python-ldap package)
        # import ldap

        # ldap_server = "ldap://your-ldap-server.com"
        # base_dn = "dc=yourcompany,dc=com"
        # user_dn = f"uid={username},{base_dn}"

        # conn = ldap.initialize(ldap_server)
        # conn.simple_bind_s(user_dn, password)

        # # If we get here, authentication succeeded
        # # Fetch user attributes
        # search_result = conn.search_s(
        #     user_dn,
        #     ldap.SCOPE_BASE,
        #     '(objectClass=*)',
        #     ['mail', 'cn', 'sn', 'givenName']
        # )

        # if search_result:
        #     attrs = search_result[0][1]
        #     return {
        #         'email': attrs.get('mail', [username])[0].decode('utf-8'),
        #         'name': attrs.get('cn', [''])[0].decode('utf-8'),
        #         'family_name': attrs.get('sn', [''])[0].decode('utf-8'),
        #         'given_name': attrs.get('givenName', [''])[0].decode('utf-8'),
        #         'legacy_id': username
        #     }

        # conn.unbind()
        return None

    except Exception as e:
        logger.error(f"Error validating LDAP credentials: {str(e)}")
        return None
