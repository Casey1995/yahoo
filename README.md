## Requirements
- AWS Account
- Terraform installed on your local machine
- Configured AWS CLI with access keys

## Providers
- Name: AWS
- Version: No specific AWS version was used for this configuration. Compatibility is expected for recent terraform versions.
- image.png

Local backend was used for the project.

## Modules
This Terraform module contains configuration that sets up an AWS environment with several key components for a Public Facing Web Stack, including API Gateway, AWS Lambda functions, AWS CloudFront distribution with WAF for rate limiting, S3 bucket for storage, KMS keys for encryption, CloudWatch for logging and monitoring, and SNS for notifications.
All modules used are are local and sourced from the public terraform documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

### AWS Services Used
1. **API Gateway (HTTP):** Serves as the front door for requests to access the text file, ensuring API calls are managed and authenticated.
2. **Lambda Functions:** Three separate functions are utilized:
   - The first function generates the text file, encrypts it using AWS KMS, and uploads it to the S3 bucket.
   - The second function retrieves and decrypts the latest file from the S3 bucket upon request.
   - The third function acts as an authorizer, implementing rate limiting based on the number of requests per IP address.
3. **Amazon Simple Storage Service (S3):** Used for storing the encrypted text files, ensuring they are securely held until requested.
4. **DynamoDB:** Maintains records of requests for rate limiting evaluation by the Lambda authorizer. It utilizes TTL settings to automatically purge records after the evaluation period, aiding in the management of storage and ensuring up-to-date request tracking.
5. **AWS Key Management Service (KMS):** Provides encryption services for the text files before they are stored in S3, ensuring data is encrypted at rest.
6. **Amazon EventBridge:** Acts as a scheduler, triggering the Lambda function responsible for file creation every 10 minutes, ensuring regular file updates.
7. **Amazon CloudWatch:** Used for logging transactions within the application, offering insights into its operation and any issues that may arise.
8. **CloudWatch Alarms and Amazon Simple Notification Service (SNS):** Works in conjunction to notify via an SNS topic when a user exceeds the rate limit, triggering an alarm and denying further access as necessary.

## Additional Resources
- AWS Terraform Provider Documentation
- AWS API Gateway
- AWS Lambda
- AWS CloudWatch
- AWS SNS
- AWS DYNAMODB
- AWS KMS

## Inputs
No Required Inputs:

## Outputs
* http_endpoint_url - The API gateway endpoint used for service requests.

## Usage
The root folder of this project contains the following directories and files 'lab' 'modules' '.gitignore' 'Architectural Diagram' and a README.md file.
The 'lab' directory contains terraform files with values local to the development environment. It references the 'modules' as it's source for resource deployment.
In the 'modules' directory are terraform files for various AWS resoruces that will be deployed for the application project. The .tf files are names very similar after the resources it contained.
Another directory 'scripts' exist inside the 'modules', it contains two more directories, each for the source code used to deploy the lambda functions.
Dependencies - A few libraries were used in the source code - boto3, datetime, json, os, ClientError.
Deployment Instructions - Navigate to the 'lab' directory and run the below terraform commands after meeting the earlier stated requirements.
NOTE - Ensure you confirm SNS subscription notification soon after deploying the SNS resources.

The `project` directory structure and its contents are organized to support the deployment and management of an AWS-based application using Terraform. Here's a concise overview:

### Project Repo Structure:
`/lab`
* This directory holds Terraform configuration files specific to the development environment. It leverages resources defined in the `modules` directory for infrastructure deployment.
`/modules`
* This directory contains Terraform files for defining the AWS resources to be deployed as part of the application. The naming convention of the `.tf` files closely mirrors the AWS resources they represent.
    `/scripts`
    * This is a subdirectory of the `module` which is subdivided into `3` different directories/files `/auth1/auth.py`, `/fetcher/latestFetcher.py`, and `/uploader/objectUploader.py` containing the source code for deploying the Lambda functions.
`/.gitignore`
* A Git configuration file used to exclude files and directories from version control.
`Architectural Diagram`
* This file provides a visual representation of the application's infrastructure architecture.
`README.md`
* This file offers detailed information about the project, including an overview, setup instructions, and any additional notes relevant to users or developers.

### Dependencies:
- The application's Lambda functions rely on several libraries, including `boto3` for AWS SDK operations, `datetime` for handling dates and times, `json` for JSON parsing, `os` for interacting with the operating system, and handling of `ClientError` exceptions.

### Deployment Instructions:
- To deploy the application's infrastructure, users are instructed to clone the `DEVELOP` branch of this git repository to a local machine, navigate to the `lab` directory. From there, they should run Terraform commands to initialize the configuration, plan the deployment, and apply the changes to create the resources in AWS.
- A note emphasizes the importance of confirming the SNS subscription notification after deploying SNS resources, ensuring that the notification system is fully operational.

## Destruction Instructions:
Running `terraform destroy` is a powerful a command that should be used with caution since it will irreversibly remove the specified resources managed by Terraform in your cloud provider.
Before You Run `terraform destroy` Ensure you empty the objects in the S3 bucket. Run `terraform plan -destroy` before executing `terraform destroy`. This command will show you what resources Terraform plans to remove without actually deleting them. It's a good practice to review this output to ensure no unintended resources are being deleted. After the command completes, verify in your cloud provider's console or CLI that the resources have indeed been removed.