import boto3
from datetime import datetime
import os
import json

# Variables
kms_key_id = os.environ['KMS_KEY_ID']
s3_bucket_name = os.environ['S3_BUCKET']

def lambda_handler(event, context):
    data = "Sensitive data. DO NOT SHARE!"
    data = f"{data}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    file_name_prefix = 'sensitive_data'

    result = create_encrypt_and_upload_file(file_name_prefix, data, kms_key_id, s3_bucket_name)
    print(result)
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }

def create_encrypt_and_upload_file(file_name_prefix, data, kms_key_id, s3_bucket_name):
    # Ensure the /tmp directory is used for Lambda or other restricted environments
    file_name = f"{file_name_prefix}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    file_path = f"/tmp/{file_name}"
    
    # Create and write data to the file
    try:
        with open(file_path, 'w') as file:
            file.write(data)
    except IOError as e:
        return f"Error creating the file: {str(e)}"
    
    # Initialize the boto3 KMS client
    kms_client = boto3.client('kms')
    
    # Read the content of the file
    try:
        with open(file_path, 'rb') as file:
            file_content = file.read()
    except IOError as e:
        return f"Error reading the file before encryption: {str(e)}"
    
    # Encrypt the content using AWS KMS
    try:
        encrypted_data = kms_client.encrypt(
            KeyId=kms_key_id,
            Plaintext=file_content
        )['CiphertextBlob']
    except kms_client.exceptions.ClientError as e:
        return f"Error encrypting the file: {str(e)}"
    
    # Write the encrypted content back to the file
    try:
        with open(file_path, 'wb') as file:
            file.write(encrypted_data)
    except IOError as e:
        return f"Error writing the encrypted data to the file: {str(e)}"
    
    # Upload the encrypted file to S3
    s3_client = boto3.client('s3')
    try:
        s3_client.upload_file(file_path, s3_bucket_name, file_name)
    except s3_client.exceptions.ClientError as e:
        return f"Error uploading the file to S3: {str(e)}"
    
    # Optionally, remove the file after upload if it's no longer needed locally
    os.remove(file_path)

    return f"File '{file_name}' has been successfully created, encrypted, and uploaded to '{s3_bucket_name}'."
