import json
import boto3

def get_secret():
    secret_name = "cloudfront_secret_token"  # The name of your secret in Secrets Manager
    region_name = "us-east-1"  # The region where your secret is stored

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise e
    else:
        # Decrypts secret using the associated KMS CMK
        secret = get_secret_value_response['SecretString']
        return secret

def lambda_handler(event, context):
    secret_token = get_secret()
    # Assuming the secret is stored as a simple string
    expected_token = json.loads(secret_token)['mySecretToken']  # Adjust the key if your secret JSON has a different structure

    token = event['headers'].get('X-My-CloudFront-Secret')

    auth_response = {
        "principalId": "user",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": "Deny",
                    "Resource": event["methodArn"]
                }
            ]
        }
    }

    if token == expected_token:
        auth_response["policyDocument"]["Statement"][0]["Effect"] = "Allow"
    else:
        auth_response["policyDocument"]["Statement"][0]["Effect"] = "Deny"

    return auth_response