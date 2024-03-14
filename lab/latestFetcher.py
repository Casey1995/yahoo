import boto3
import json
from operator import itemgetter
import os

def handler(event, context):

    s3 = boto3.client('s3')
    # Your target S3 bucket
    bucket = os.environ['S3_BUCKET']
    try:
        # List objects in the bucket
        objects = s3.list_objects_v2(Bucket=bucket)
        # Sort objects by last modified date
        sorted_objects = sorted(objects.get('Contents', []), key=itemgetter('LastModified'), reverse=True)
        return f"Successfully pulled the latest file from S3."
    except Exception as e:
        print(e)
        return "Encountered an error pulling the file from S3."
