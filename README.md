## Requirements
AWS Account
Terraform installed on your local machine
Configured AWS CLI with access keys

## Providers
Name: AWS
Version: No specific AWS version was used for this configuration. Compatibility is expected for recent terraform versions.
image.png

Local backend was used for the project.

## Modules
This Terraform module contains configuration that sets up an AWS environment with several key components for a Public Facing Web Stack, including API Gateway, AWS Lambda functions, AWS CloudFront distribution with WAF for rate limiting, S3 bucket for storage, KMS keys for encryption, CloudWatch for logging and monitoring, and SNS for notifications.
All modules used are are local and sourced from the public terraform documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## Resources
API Gateway (HTTP API): Acts as the front door for your web application.
AWS Lambda: Serverless compute service running your application code in response to events.
CloudFront Distribution: Content Delivery Network (CDN) service that securely delivers data to customers globally with low latency.
WAF (Web Application Firewall): Protects your web applications from common web exploits.
CloudWatch: Monitoring and observability service for AWS cloud resources and the applications you run on AWS.
SNS (Simple Notification Service): Pub/sub messaging and mobile notifications service for coordinating the delivery of messages to subscribing endpoints and clients.
IAM Roles and Policies: AWS Identity and Access Management roles and policies for securely controlling access to AWS services and resources.
AWS KMS Keys: Security service that provides data encryption for at rest and in-transit data.

## Additional Resources
AWS Terraform Provider Documentation
AWS API Gateway
AWS Lambda
AWS CloudFront
AWS WAF
AWS CloudWatch
AWS SNS

## Inputs
Required Inputs:
* origin_domain_name - string - The endpoint serving your origin content.
* default_cache_behaviour - Map of default cache behaviour attributes.
* web_acl_id - string - Unique identifier that specifies the AWS WAF web ACL to associate with this distribution.
* origin_id - The API endpoint used as origin for the cloudfront

## Outputs
* cloudfront_arn - The ARN of the cloudfront distribution.
* cloudfront_domain_name - The public domain name generated for the cloudfront distribution.
* web_acl_id - Unique identifier that specifies the AWS WAF web ACL to associate with this distribution.
* http_endpoint_url - The API gateway endpoint used as cloudfront origin.

## Usage
To root folder of this project 'project_yahoo' contains the following directories and files 'lab' 'modules' '.gitignore' 'Architectural Diagram' and a README.md file.
The 'lab' directory contains terraform files with values local to the development environment. It references the 'modules' as it's source for resource deployment.
In the 'modules' directory are terraform files for various AWS resoruces that will be deployed for the application project. The .tf files are names very similar after the resources it contained.
Another directory 'scripts' exist inside the 'modules', it contains two more directories, each for the source code used to deploy the lambda functions.
Dependencies - A few libraries were used in the source code - boto3, datetime, json, os, ClientError.
Deployment Instructions - Navigate to the 'lab' directory and run the below terraform commands after meeting the earlier stated requirements.

NOTE - Ensure you confirm SNS subscription notification soon after deploying the SNS resources.

Initialization: Navigate to your Terraform configuration directory and initialize Terraform.
*    terraform init
Planning: Review the changes Terraform will perform.
*    terraform plan
Apply: Apply the changes to set up your AWS environment.
*    terraform apply
Destroy (Optional): Remove all resources created by Terraform.
*    terraform destroy
        To successfully destroy all the resources. Ensure the S3 bucket is empty. Errors may occur when deleting S3 bucket with objects.

