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
AWS Terraform Provider Documentation
AWS API Gateway
AWS Lambda
AWS CloudWatch
AWS SNS
AWS DYNAMODB
AWS KMS

## Inputs
No Required Inputs:

## Outputs
* http_endpoint_url - The API gateway endpoint used as cloudfront origin.

## Usage
To root folder of this project 'project_yahoo' contains the following directories and files 'lab' 'modules' '.gitignore' 'Architectural Diagram' and a README.md file.
The 'lab' directory contains terraform files with values local to the development environment. It references the 'modules' as it's source for resource deployment.
In the 'modules' directory are terraform files for various AWS resoruces that will be deployed for the application project. The .tf files are names very similar after the resources it contained.
Another directory 'scripts' exist inside the 'modules', it contains two more directories, each for the source code used to deploy the lambda functions.
Dependencies - A few libraries were used in the source code - boto3, datetime, json, os, ClientError.
Deployment Instructions - Navigate to the 'lab' directory and run the below terraform commands after meeting the earlier stated requirements.
NOTE - Ensure you confirm SNS subscription notification soon after deploying the SNS resources.

The `project_yahoo` directory structure and its contents are organized to support the deployment and management of an AWS-based application using Terraform. Here's a concise overview:

### Project Structure:
- **Root Folder (`project_yahoo`)**: Contains key directories and files essential for the project, including:
  - `lab`: Holds Terraform configuration files specific to the development environment. It leverages resources defined in the `modules` directory for infrastructure deployment.
  - `modules`: Contains Terraform files for defining the AWS resources to be deployed as part of the application. The naming convention of the `.tf` files closely mirrors the AWS resources they represent.
    - Inside `modules`, a `scripts` subdirectory exists, which is further divided into three directories containing the source code for deploying the Lambda functions.
  - `.gitignore`: A Git configuration file used to exclude files and directories from version control.
  - `Architectural Diagram`: Provides a visual representation of the application's infrastructure architecture.
  - `README.md`: Offers detailed information about the project, including an overview, setup instructions, and any additional notes relevant to users or developers.

### Dependencies:
- The application's Lambda functions rely on several libraries, including `boto3` for AWS SDK operations, `datetime` for handling dates and times, `json` for JSON parsing, `os` for interacting with the operating system, and handling of `ClientError` exceptions.

### Deployment Instructions:
- To deploy the application's infrastructure, users are instructed to navigate to the `lab` directory. From there, they should run Terraform commands to initialize the configuration, plan the deployment, and apply the changes to create the resources in AWS.
- A note emphasizes the importance of confirming the SNS subscription notification after deploying SNS resources, ensuring that the notification system is fully operational.

## Destruction Instructions:
Running `terraform destroy` is a powerful a command that should be used with caution since it will irreversibly remove the specified resources managed by Terraform in your cloud provider.
Before You Run `terraform destroy` Ensure you empty the objects in the S3 bucket. Run `terraform plan -destroy` before executing `terraform destroy`. This command will show you what resources Terraform plans to remove without actually deleting them. It's a good practice to review this output to ensure no unintended resources are being deleted. After the command completes, verify in your cloud provider's console or CLI that the resources have indeed been removed.

### Solution Overview
This solution leverages multiple AWS services to create, encrypt, and serve text files, with a focus on security and rate limiting to manage access.
The solution automatically generates a text file every 10 minutes, applies a timestamp, encrypts it using AWS Key Management Service (KMS), and stores it in an Amazon Simple Storage Service (S3) bucket. It restricts file access via an API Gateway (HTTP) endpoint, limiting requests to 210 per IP address every 10 minutes. The AWS public cloud hosts this solution, incorporating various services for scheduling, storage, encryption, request handling, authorization, logging, and notifications.

### Solution Flow
1. **File Generation and Storage:** Every 10 minutes, EventBridge triggers a Lambda function to create, encrypt, and upload a new text file to S3.
2. **Request Handling and Rate Limiting:** When a file is requested via the API Gateway, a Lambda function checks the request rate for the requesting IP address using DynamoDB. If under the limit, the latest file is fetched from S3, decrypted, and served. Otherwise, access is denied.
3. **Logging and Notifications:** All transactions are logged to CloudWatch, and any rate limit exceedances trigger an alarm, sending a notification through SNS.

This architecture showcases a scalable, secure method for file management and distribution, emphasizing automated processes, encryption for security, and effective request rate limiting to prevent abuse.

## Alternatives
Alternative services for implementing rate limiting and compare them with the Lambda function approach, highlighting why Lambda might be more efficient for this particular solution.
### CloudFront and WAF for Rate Limiting
**Amazon CloudFront** is a content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency and high transfer speeds. **AWS WAF (Web Application Firewall)** is a web application firewall that helps protect web applications or APIs against common web exploits and bots that may affect availability, compromise security, or consume excessive resources.

- **Rate Limiting with CloudFront and WAF**: You can implement rate limiting using AWS WAF by creating a rate-based rule that tracks the number of requests coming from a single IP address and blocks further requests once a threshold is exceeded within a specified time period. This rule can be associated with a CloudFront distribution to protect content delivered through CDN.
- **Considerations**: While CloudFront and WAF provide robust security and content delivery features, including rate limiting, they may introduce more complexity and cost to your solution. AWS WAF incurs charges based on the number of rules you deploy and the amount of web requests your application receives. When combined with CloudFront, you also pay for the data transfer and requests handled by the CDN. For small to medium-sized solutions, or where the primary requirement is rate limiting without the need for global content delivery, this setup might be overkill.

### EC2 Instances for Rate Limiting
**Amazon EC2 (Elastic Compute Cloud)** instances provide resizable compute capacity in the cloud. They allow you to run servers and scale computing capacity as needed.

- **Rate Limiting with EC2**: Implementing rate limiting on EC2 instances would typically involve configuring your application or web server (e.g., Nginx, Apache) with specific rate limiting rules. This approach gives you granular control over the rate limiting logic but requires managing the underlying infrastructure, including server setup, scaling, and security.
- **Considerations**: EC2 instances offer the most flexibility since you can run any software and implement any logic you need. However, they also require the most management and can incur higher costs, especially if you need to scale out to handle high traffic. You're responsible for managing the server's lifecycle, including scaling, patching, and securing the instances.

### Lambda for Rate Limiting
**AWS Lambda** allows you to run code without provisioning or managing servers. You pay only for the compute time you consume, making it a cost-effective way to run applications.

- **Efficiency of Lambda**: Using Lambda functions for tasks like generating files, handling requests, and implementing rate limiting can be more efficient and cost-effective, especially for workloads with variable traffic. Lambda functions scale automatically, and you don't need to manage any servers. The rate limiting logic, as implemented via a Lambda authorizer or within the function itself, can be tightly integrated with API Gateway, simplifying deployment and management.
- **Considerations**: While Lambda simplifies many aspects of application deployment and scalability, implementing rate limiting within a Lambda function does require custom coding and management of state (e.g., request counts) in an external service like DynamoDB as used here. However, this approach offers a good balance between flexibility, cost, and ease of management for many use cases.

### Conclusion
While CloudFront and WAF provide powerful, managed solutions for rate limiting with additional benefits like DDoS protection and global content delivery, they may introduce additional cost and complexity not warranted for all projects. EC2 instances offer the most control but require significant management and can be less cost-effective for fluctuating workloads. Lambda functions strike a balance by offering serverless execution, automatic scaling, and a pay-for-what-you-use model, making them an efficient choice for scenarios described in the solution, especially when combined with AWS-native services like API Gateway and DynamoDB for seamless integration and management.

## Recommandations - Implement Dashboard for Visualization
Use CloudWatch Dashboards to create a unified view of the resources and metrics that matter most. A dashboard can visualize the health and performance of the entire solution, allowing you to spot trends and issues at a glance.

## Disaster Recovery Consideration
* This solution is NOT multi region deployed. However, for a robust DR consideration, deploy solution across multiple AWS regions. This includes replicating your API Gateway setup, Lambda functions, DynamoDB tables, S3 buckets, and other resources used across at least two regions. Use Iac tool to manage infrastructure as code, ensuring consistent deployments across regions.
* Enable Cross-Region Replication (CRR) for your S3 buckets to automatically replicate objects across buckets in different AWS regions. Remember to use Multi Region Keys for encryption.
* Utilize DynamoDB Global Tables for automatic data replication across multiple regions. This ensures your rate-limiting data is up-to-date in all regions. Ensure automated backups for DynamoDB using point-in-time recovery (PITR). Document and automate the restore process to reduce recovery time.
* Use Amazon Route 53 to manage DNS and route traffic to the appropriate regional endpoint based on health checks and geographic location.
* Replicate your Lambda functions across regions. You can automate this process using CI/CD pipelines to ensure that any updates to your functions are consistently deployed across all regions.

## Compliance with AWS Well-Architected Framework.
Operational Excellence, Security, Reliability, Performance Efficiency, and Cost Optimization.

### Operational Excellence
* By using EventBridge for scheduling, Lambda for serverless computing, and DynamoDB for data storage, the solution automates operational tasks, such as file generation and rate limiting, enhancing operational efficiency. Automated notifications and utilizing CloudWatch for monitoring and logging enables the tracking of application health and performance, facilitating quick responses to operational issues.

### Security
* Leveraging AWS KMS for encryption ensures that the generated text files are encrypted at rest, enhancing data security.
* Implementing role-based access control and using IAM roles with minimal necessary permissions for Lambda functions and other services adhere to the principle of least privilege.
* custom Lambda authorizer for API Gateway enforces strict access control, and manage resource utilization with rate limits.
* The use of private link for communication between resources in the VPC.

### Reliability
* Lambda function is a fully managed service that can run your code from any availability zone or region specified.
* S3 Versioning to enable recovery from accidental deletion of s3 objects.

### Performance Efficiency
* Leveraging serverless services like Lambda, DynamoDB, and S3 ensures that resources are efficiently allocated and scaled automatically based on demand, optimizing performance.

### Cost Optimization
* The solution's reliance on serverless computing and managed services follows a pay-as-you-go pricing model, ensuring you only pay for the resources you use, which can lead to significant cost savings.
* Using EventBridge to trigger Lambda functions on a schedule avoids unnecessary executions, and DynamoDB's ttl setting ensures that data are not kept beyond it's usage.
* The use of S3 Lifecycle rule to manage object storage classes.