import boto3
import os
from botocore.exceptions import ClientError
import json

# kms_key_id = os.environ['KMS_KEY_ID']
# s3_bucket_name = os.environ['S3_BUCKET']
# Initialize the S3 and KMS clients outside of the handler for better performance
s3_client = boto3.client('s3')
kms_client = boto3.client('kms')

def lambda_handler(event, context):
    bucket_name = os.environ['S3_BUCKET']
    #key_prefix = 'your-key-prefix'  # Optional: Specify a prefix if the files are in a specific folder

    try:
        # Fetch the list of objects in the bucket
        response = s3_client.list_objects_v2(Bucket=bucket_name) #, Prefix=key_prefix)
        # Sort the objects by last modified date
        objects = sorted(response.get('Contents', []), key=lambda obj: obj['LastModified'], reverse=True)

        if not objects:
            return {'statusCode': 404, 'body': 'No files found in the bucket.'}

        # Get the key of the latest file
        latest_file_key = objects[0]['Key']

        # Download the latest file
        download_path = f"/tmp/{latest_file_key.split('/')[-1]}"
        s3_client.download_file(bucket_name, latest_file_key, download_path)

        # Decrypt the file content using KMS
        with open(download_path, 'rb') as encrypted_file:
            encrypted_data = encrypted_file.read()
        
        decrypted_data = kms_client.decrypt(CiphertextBlob=encrypted_data)['Plaintext']
        
        # Optionally, convert the decrypted content to a string if expected to be text
        decrypted_content = decrypted_data.decode('utf-8')

        return {
            'statusCode': 200,
            'body': decrypted_content
        }

    except ClientError as e:
        return {'statusCode': 500, 'body': f"Error accessing S3 or decrypting file: {str(e)}"}