import json
import boto3
import logging
from datetime import datetime, timedelta

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
cloudwatch = boto3.client('cloudwatch')
table = dynamodb.Table('RateLimitTable')

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    try:
        ipAddress = event['identitySource']
        ipAddress = ipAddress[0]
        time_window = datetime.now() - timedelta(minutes=10)
        currenttime = int(time_window.timestamp() * 1000)
        currenttime = int(currenttime)
        accountId = event['requestContext']['accountId']
        apiId = event['requestContext']['apiId']
        region = "us-east-1"
        stage = event['requestContext']['stage']
        httpMethod = event['requestContext']['http']['method']
        resourcePath = event['requestContext']['http']['path']

        methodArn = f"arn:aws:execute-api:{region}:{accountId}:{apiId}/{stage}/{httpMethod}{resourcePath}"
        
        # logger.info(f"Querying with IP: {ipAddress} (Type: {type(ipAddress)}) and Time: {currenttime} (Type: {type(currenttime)})")
        response = table.query(
            KeyConditionExpression='ipAddress = :ip and currenttime = :time',
            ExpressionAttributeValues={
                ':ip': ipAddress,
                ':time': currenttime,
            }
        )
        request_count = response['Count']
        
        if request_count >= 210:
            logger.info(f"Rate limit exceeded for IP: {ipAddress}")
            publish_to_cloudwatch(ipAddress)
            return generate_policy('user', 'Deny', methodArn)
        else:
            record_request(ipAddress)
            return generate_policy('user', 'Allow', methodArn)
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return generate_policy('user', 'Deny', methodArn)

def record_request(ipAddress):
    try:
        table.put_item(
            Item={
                'ipAddress': ipAddress,
                'currenttime': int(datetime.now().timestamp() * 1000),
                'ttl': int((datetime.now() + timedelta(minutes=10)).timestamp()),
            }
        )
    except Exception as e:
        logger.error(f"Failed to record request for IP: {ipAddress}, Error: {str(e)}")

def publish_to_cloudwatch(ipAddress):
    try:
        cloudwatch.put_metric_data(
            Namespace='MyAPIGatewayUsage',
            MetricData=[
                {
                    'MetricName': 'RateLimitExceeded',
                    'Dimensions': [
                        {
                            'Name': 'IPAddress',
                            'Value': ipAddress
                        },
                    ],
                    'Value': 1,
                    'Unit': 'Count'
                },
            ]
        )
    except Exception as e:
        logger.error(f"Failed to publish to CloudWatch for IP: {ipAddress}, Error: {str(e)}")

def generate_policy(principal_id, effect, resource):
    auth_response = {'principalId': principal_id}
    if effect and resource:
        policy_document = {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
        auth_response['policyDocument'] = policy_document
    return auth_response