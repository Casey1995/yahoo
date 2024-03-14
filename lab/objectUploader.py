# import boto3
# import os
# import logging
# from datetime import datetime
# from cryptography.fernet import Fernet

# # Configure logging
# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# def lambda_handler(event, context):
#     # Get environment variables
#     bucket_name = os.environ['S3_BUCKET']
#     kms_key_id = os.environ['KMS_KEY_ID']

#     try:
#         # Generate file content (replace with your actual generation logic)
#         file_content = b"This is the content of my generated file."

#         # Get timestamp 
#         timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
#         file_name = f"generated_file_{timestamp}.txt"

#         # Encryption using KMS and Fernet
#         kms_client = boto3.client('kms')
#         response = kms_client.generate_data_key(KeyId=kms_key_id, KeySpec='AES_256')
#         cipher_key = Fernet(response['Plaintext'])
#         encrypted_content = cipher_key.encrypt(file_content)

#         # Upload to S3
#         s3 = boto3.client('s3')
#         s3.put_object(
#             Bucket=bucket_name,
#             Key=file_name,
#             Body=encrypted_content
#         )

#         logger.info(f'File {file_name} uploaded successfully') 
#         return {
#             'statusCode': 200,
#             'message': f'File {file_name} uploaded successfully' 
#         }

#     except Exception as e:
#         logger.error(f"An error occurred: {e}")
#         return {
#             'statusCode': 500,
#             'message': 'An error occurred during file processing'
#         }


##########################################################################
import boto3
from datetime import datetime
import os
from cryptography.fernet import Fernet

def lambda_handler(event, context):
    # Your target S3 bucket and KMS key ID
    bucket_name = os.environ['S3_BUCKET']
    kms_key_id = os.environ['KMS_KEY_ID']  # The ARN or alias of the KMS key

    # Generate a file with a timestamp in the /tmp directory
    #file_name = f"/tmp/file_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    file_name = f"/tmp/yahoo_file_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    with open(file_name, 'w') as file:
        file.write('This time: {current_time} will never come again')

    # Encryption using KMS and Fernet
    kms_client = boto3.client('kms')
    response = kms_client.generate_data_key(KeyId=kms_key_id, KeySpec='AES_256')
    cipher_key = Fernet(response['Plaintext'])
    encrypted_file = cipher_key.encrypt(file_name)

    # Initialize the boto3 client
    s3_client = boto3.client('s3')

    # Upload the file to S3 with server-side encryption using KMS
    try:
        with open(file_name, 'rb') as file:
            s3_client.upload_fileobj(
                Fileobj=file,
                Bucket=bucket_name,
                Key=file_name.split('/')[-1],  # Remove the /tmp/ path
                ExtraArgs={
                    'ServerSideEncryption': 'aws:kms',
                    'SSEKMSKeyId': kms_key_id
                }
            )
        return f"File {file_name.split('/')[-1]} successfully uploaded and encrypted with KMS."
    except Exception as e:
        print(e)
        return "Error uploading the file to S3."
