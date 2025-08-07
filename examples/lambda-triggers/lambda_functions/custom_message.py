"""
Custom Message Lambda Trigger for Amazon Cognito

This function is triggered when Cognito needs to send a message to a user. It can be used to:
- Customize email and SMS messages
- Localize messages based on user preferences
- Add branding and styling
- Implement custom message templates
- Add dynamic content to messages

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
    "triggerSource": "CustomMessage_SignUp",
    "request": {
        "userAttributes": {
            "email": "user@example.com"
        },
        "codeParameter": "{####}",
        "linkParameter": "{##Click Here##}",
        "usernameParameter": "{username}",
        "clientMetadata": {}
    },
    "response": {
        "smsMessage": "",
        "emailMessage": "",
        "emailSubject": ""
    }
}
"""

import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Custom Message Lambda trigger handler
    """
    logger.info(f"Custom Message trigger invoked: {json.dumps(event, default=str)}")

    try:
        # Extract event information
        trigger_source = event['triggerSource']
        username = event['userName']
        user_attributes = event['request']['userAttributes']
        code_parameter = event['request']['codeParameter']
        link_parameter = event['request']['linkParameter']
        username_parameter = event['request']['usernameParameter']
        client_metadata = event['request'].get('clientMetadata', {})

        email = user_attributes.get('email', '')
        name = user_attributes.get('name', username)

        logger.info(f"Customizing message for trigger: {trigger_source}, user: {username}")

        # Get user's preferred language (if available)
        preferred_language = user_attributes.get('locale', 'en')

        # Customize messages based on trigger source
        if trigger_source == 'CustomMessage_SignUp':
            customize_signup_message(event, name, email, code_parameter, link_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_AdminCreateUser':
            customize_admin_create_user_message(event, name, email, code_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_ResendCode':
            customize_resend_code_message(event, name, email, code_parameter, link_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_ForgotPassword':
            customize_forgot_password_message(event, name, email, code_parameter, link_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_UpdateUserAttribute':
            customize_update_attribute_message(event, name, email, code_parameter, link_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_VerifyUserAttribute':
            customize_verify_attribute_message(event, name, email, code_parameter, link_parameter, preferred_language)

        elif trigger_source == 'CustomMessage_Authentication':
            customize_authentication_message(event, name, email, code_parameter, preferred_language)

        else:
            logger.warning(f"Unknown trigger source: {trigger_source}")
            # Provide default messages
            customize_default_message(event, name, email, code_parameter, preferred_language)

        logger.info(f"Custom message processing completed for trigger: {trigger_source}")
        return event

    except Exception as e:
        logger.error(f"Custom message trigger failed: {str(e)}")
        # Return the event with default messages if customization fails
        return event

def customize_signup_message(event, name, email, code_parameter, link_parameter, language):
    """
    Customize sign-up verification message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        if language == 'es':
            # Spanish messages
            event['response']['emailSubject'] = f'Verifica tu cuenta en {project_name}'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>¡Hola {name}!</h2>
                    <p>Gracias por registrarte en {project_name}. Para completar tu registro, por favor verifica tu dirección de correo electrónico.</p>
                    <p>Tu código de verificación es: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>O puedes hacer clic en el siguiente enlace:</p>
                    <p style="text-align: center;">
                        <a href="#" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">{link_parameter}</a>
                    </p>
                    <p style="color: #666; font-size: 12px;">Este código expirará en 24 horas.</p>
                </div>
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px;">
                    <p>Si no solicitaste esta verificación, puedes ignorar este correo.</p>
                </div>
            </body>
            </html>
            '''
            event['response']['smsMessage'] = f'Tu código de verificación para {project_name} es: {code_parameter}'

        else:
            # English messages (default)
            event['response']['emailSubject'] = f'Verify your {project_name} account'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>Hello {name}!</h2>
                    <p>Thank you for signing up for {project_name}. To complete your registration, please verify your email address.</p>
                    <p>Your verification code is: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>Or you can click the link below:</p>
                    <p style="text-align: center;">
                        <a href="#" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">{link_parameter}</a>
                    </p>
                    <p style="color: #666; font-size: 12px;">This code will expire in 24 hours.</p>
                </div>
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px;">
                    <p>If you didn't request this verification, you can safely ignore this email.</p>
                </div>
            </body>
            </html>
            '''
            event['response']['smsMessage'] = f'Your {project_name} verification code is: {code_parameter}'

        logger.info(f"Sign-up message customized for language: {language}")

    except Exception as e:
        logger.error(f"Failed to customize sign-up message: {str(e)}")

def customize_admin_create_user_message(event, name, email, code_parameter, language):
    """
    Customize admin create user message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        if language == 'es':
            event['response']['emailSubject'] = f'Tu cuenta en {project_name} ha sido creada'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>¡Bienvenido {name}!</h2>
                    <p>Se ha creado una cuenta para ti en {project_name}.</p>
                    <p>Tu nombre de usuario es: <strong>{email}</strong></p>
                    <p>Tu contraseña temporal es: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>Por favor, inicia sesión y cambia tu contraseña en tu primer acceso.</p>
                    <p style="color: #666; font-size: 12px;">Esta contraseña temporal expirará en 7 días.</p>
                </div>
            </body>
            </html>
            '''
        else:
            event['response']['emailSubject'] = f'Your {project_name} account has been created'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>Welcome {name}!</h2>
                    <p>An account has been created for you on {project_name}.</p>
                    <p>Your username is: <strong>{email}</strong></p>
                    <p>Your temporary password is: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>Please sign in and change your password on your first login.</p>
                    <p style="color: #666; font-size: 12px;">This temporary password will expire in 7 days.</p>
                </div>
            </body>
            </html>
            '''

        logger.info(f"Admin create user message customized for language: {language}")

    except Exception as e:
        logger.error(f"Failed to customize admin create user message: {str(e)}")

def customize_forgot_password_message(event, name, email, code_parameter, link_parameter, language):
    """
    Customize forgot password message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        if language == 'es':
            event['response']['emailSubject'] = f'Restablece tu contraseña de {project_name}'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>Hola {name},</h2>
                    <p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en {project_name}.</p>
                    <p>Tu código de restablecimiento es: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>O puedes hacer clic en el siguiente enlace:</p>
                    <p style="text-align: center;">
                        <a href="#" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">{link_parameter}</a>
                    </p>
                    <p style="color: #666; font-size: 12px;">Este código expirará en 1 hora.</p>
                </div>
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px;">
                    <p>Si no solicitaste este restablecimiento, puedes ignorar este correo.</p>
                </div>
            </body>
            </html>
            '''
        else:
            event['response']['emailSubject'] = f'Reset your {project_name} password'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                    <h1 style="color: #007bff;">{project_name}</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>Hello {name},</h2>
                    <p>We received a request to reset the password for your {project_name} account.</p>
                    <p>Your reset code is: <strong style="font-size: 18px; color: #007bff;">{code_parameter}</strong></p>
                    <p>Or you can click the link below:</p>
                    <p style="text-align: center;">
                        <a href="#" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">{link_parameter}</a>
                    </p>
                    <p style="color: #666; font-size: 12px;">This code will expire in 1 hour.</p>
                </div>
                <div style="background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px;">
                    <p>If you didn't request this reset, you can safely ignore this email.</p>
                </div>
            </body>
            </html>
            '''

        logger.info(f"Forgot password message customized for language: {language}")

    except Exception as e:
        logger.error(f"Failed to customize forgot password message: {str(e)}")

def customize_resend_code_message(event, name, email, code_parameter, link_parameter, language):
    """
    Customize resend code message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        if language == 'es':
            event['response']['emailSubject'] = f'Tu nuevo código de verificación para {project_name}'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="padding: 30px;">
                    <h2>Hola {name},</h2>
                    <p>Aquí tienes tu nuevo código de verificación para {project_name}:</p>
                    <p style="text-align: center; font-size: 24px; color: #007bff; font-weight: bold;">{code_parameter}</p>
                    <p>O puedes hacer clic aquí: {link_parameter}</p>
                </div>
            </body>
            </html>
            '''
        else:
            event['response']['emailSubject'] = f'Your new verification code for {project_name}'
            event['response']['emailMessage'] = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="padding: 30px;">
                    <h2>Hello {name},</h2>
                    <p>Here's your new verification code for {project_name}:</p>
                    <p style="text-align: center; font-size: 24px; color: #007bff; font-weight: bold;">{code_parameter}</p>
                    <p>Or you can click here: {link_parameter}</p>
                </div>
            </body>
            </html>
            '''

        logger.info(f"Resend code message customized for language: {language}")

    except Exception as e:
        logger.error(f"Failed to customize resend code message: {str(e)}")

def customize_update_attribute_message(event, name, email, code_parameter, link_parameter, language):
    """
    Customize update user attribute message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        event['response']['emailSubject'] = f'Verify your updated information - {project_name}'
        event['response']['emailMessage'] = f'''
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="padding: 30px;">
                <h2>Hello {name},</h2>
                <p>Please verify your updated information for {project_name}:</p>
                <p>Verification code: <strong>{code_parameter}</strong></p>
                <p>Or click here: {link_parameter}</p>
            </div>
        </body>
        </html>
        '''

    except Exception as e:
        logger.error(f"Failed to customize update attribute message: {str(e)}")

def customize_verify_attribute_message(event, name, email, code_parameter, link_parameter, language):
    """
    Customize verify user attribute message
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        event['response']['emailSubject'] = f'Verify your information - {project_name}'
        event['response']['emailMessage'] = f'''
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="padding: 30px;">
                <h2>Hello {name},</h2>
                <p>Please verify your information for {project_name}:</p>
                <p>Verification code: <strong>{code_parameter}</strong></p>
                <p>Or click here: {link_parameter}</p>
            </div>
        </body>
        </html>
        '''

    except Exception as e:
        logger.error(f"Failed to customize verify attribute message: {str(e)}")

def customize_authentication_message(event, name, email, code_parameter, language):
    """
    Customize authentication message (for MFA)
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        if language == 'es':
            event['response']['smsMessage'] = f'Tu código de autenticación para {project_name} es: {code_parameter}'
        else:
            event['response']['smsMessage'] = f'Your {project_name} authentication code is: {code_parameter}'

        logger.info(f"Authentication message customized for language: {language}")

    except Exception as e:
        logger.error(f"Failed to customize authentication message: {str(e)}")

def customize_default_message(event, name, email, code_parameter, language):
    """
    Provide default message customization
    """
    try:
        project_name = os.environ.get('PROJECT_NAME', 'Our Platform')

        event['response']['emailSubject'] = f'{project_name} - Verification Required'
        event['response']['emailMessage'] = f'''
        <html>
        <body style="font-family: Arial, sans-serif;">
            <h2>Hello {name},</h2>
            <p>Your verification code is: <strong>{code_parameter}</strong></p>
        </body>
        </html>
        '''
        event['response']['smsMessage'] = f'Your {project_name} code is: {code_parameter}'

    except Exception as e:
        logger.error(f"Failed to customize default message: {str(e)}")
