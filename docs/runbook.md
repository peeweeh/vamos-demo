# Runbook: Singapore Demo Stack

This document provides step-by-step instructions for deploying and populating the "Leet" demo stack in the `ap-southeast-1` region.

## 1. Prerequisites
- AWS CLI configured with credentials that have permission to create the resources in the stack.
- An AWS account where the Service Control Policies (SCPs) do not block the creation of the required resources.

## 2. Stack Deployment
Deploy the CloudFormation stack using the following command. This will create all the necessary AWS resources.

```bash
aws cloudformation deploy \
  --template-file cloudformation/leet-sg-stack.yaml \
  --stack-name leet-sg-demo-stack \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region ap-southeast-1
```

## 3. Data Seeding
After the stack has been successfully created, run the `runbook.sh` script to populate the services with sample data. This makes the demo more realistic for Cloud Rewind discovery.

First, make the script executable:
```bash
chmod +x docs/runbook.sh
```

Then, run the script:
```bash
./docs/runbook.sh
```

The script will automatically detect your AWS Account ID and populate the following services:
- **Amazon S3**: Uploads a sample file.
- **Amazon DynamoDB**: Adds a sample item.
- **Amazon SQS**: Sends a sample message.
- **Amazon SNS**: Publishes a sample message.
- **AWS Lambda**: Invokes the function with a sample payload.
