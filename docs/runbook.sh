#!/bin/bash

# This script populates the AWS resources created by the CloudFormation stack
# with sample data.

# --- Configuration ---
# Set the AWS region where your stack is deployed
REGION="ap-southeast-1"

# Automatically get the AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$ACCOUNT_ID" ]; then
    echo "Error: Could not retrieve AWS Account ID. Please ensure you are logged in to the AWS CLI."
    exit 1
fi

echo "Using AWS Account ID: $ACCOUNT_ID"
echo "Using Region: $REGION"

# --- Temporary Files ---
echo "Creating temporary files for data seeding..."
# Create a temporary file for the S3 upload
S3_FILE_CONTENT="This is a sample file for the S3 bucket, uploaded by a script."
S3_LOCAL_PATH="/tmp/sample-s3-file.txt"
echo "$S3_FILE_CONTENT" > "$S3_LOCAL_PATH"

# Create a temporary file for the SQS message body
SQS_MESSAGE_BODY='{"message": "This is a test message from the CLI script."}'
SQS_LOCAL_PATH="/tmp/sqs-message.json"
echo "$SQS_MESSAGE_BODY" > "$SQS_LOCAL_PATH"

# --- AWS CLI Commands ---

echo "--------------------------------------------------"
echo "1. Uploading a sample file to S3..."
aws s3 cp "$S3_LOCAL_PATH" "s3://leet-sg-app-data-$ACCOUNT_ID/seed/sample-from-script.txt" --region "$REGION"
if [ $? -eq 0 ]; then echo "=> Success"; else echo "=> Failed"; fi

echo "--------------------------------------------------"
echo "2. Adding an item to DynamoDB..."
aws dynamodb put-item \
    --table-name leet-sg-ddb \
    --item '{"id": {"S": "script-sample-item"}, "data": {"S": "This item was added from the runbook.sh script."}}' \
    --region "$REGION"
if [ $? -eq 0 ]; then echo "=> Success"; else echo "=> Failed"; fi

echo "--------------------------------------------------"
echo "3. Sending a message to SQS..."
SQS_QUEUE_URL="https://sqs.$REGION.amazonaws.com/$ACCOUNT_ID/leet-sg-queue"
aws sqs send-message \
    --queue-url "$SQS_QUEUE_URL" \
    --message-body "file://$SQS_LOCAL_PATH" \
    --region "$REGION"
if [ $? -eq 0 ]; then echo "=> Success"; else echo "=> Failed"; fi

echo "--------------------------------------------------"
echo "4. Publishing a message to SNS..."
SNS_TOPIC_ARN="arn:aws:sns:$REGION:$ACCOUNT_ID:leet-sg-topic"
aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --message "Hello from the runbook.sh script!" \
    --subject "Test Notification from Script" \
    --region "$REGION"
if [ $? -eq 0 ]; then echo "=> Success"; else echo "=> Failed"; fi

echo "--------------------------------------------------"
echo "5. Invoking the Lambda function..."
LAMBDA_OUTPUT_PATH="/tmp/lambda-output.txt"
aws lambda invoke \
    --function-name leet-sg-hello \
    --payload '{"source": "runbook.sh"}' \
    "$LAMBDA_OUTPUT_PATH" \
    --region "$REGION"
if [ $? -eq 0 ]; then
    echo "=> Success. Lambda output written to $LAMBDA_OUTPUT_PATH"
    cat "$LAMBDA_OUTPUT_PATH"
    echo ""
else
    echo "=> Failed"
fi

# --- Cleanup ---
echo "--------------------------------------------------"
echo "Cleaning up temporary files..."
rm "$S3_LOCAL_PATH"
rm "$SQS_LOCAL_PATH"
rm "$LAMBDA_OUTPUT_PATH"
echo "Done."
