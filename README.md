# Leet by Vamos - Cloud Rewind Singapore Stack

This repository contains the CloudFormation template and supporting documentation for deploying a sample application stack in the `ap-southeast-1` (Singapore) region. The purpose of this stack is to provide a comprehensive set of AWS resources that can be discovered and managed by Cloud Rewind.

## Architecture

The stack deploys a three-tier web application along with a variety of serverless components.

### Core Application
- **VPC**: A custom VPC (`10.11.0.0/16`) with public, application, and database subnets across two Availability Zones.
- **Application Load Balancer**: A public-facing ALB that routes traffic to the web tier.
- **EC2 Auto Scaling Group**: A single `t3.micro` EC2 instance running a basic nginx web server.
- **RDS MySQL**: A `db.t4g.micro` single-AZ MySQL database for the application's backend.

### Serverless & Auxiliary Components
- **Amazon S3**: An S3 bucket (`leet-sg-app-data`) for application assets.
- **Amazon DynamoDB**: A simple on-demand table (`leet-sg-ddb`).
- **Amazon SQS**: A standard queue (`leet-sg-queue`).
- **Amazon SNS**: A topic for notifications (`leet-sg-topic`).
- **AWS Lambda**: A basic Python function (`leet-sg-hello`).

## Deployment

The project consists of two CloudFormation stacks:

1.  **Main Stack (Singapore)**: Deploys the primary application and services in `ap-southeast-1`.
2.  **Tokyo Bucket Stack**: Deploys a supplementary S3 bucket in `ap-northeast-1`.

For detailed instructions on how to deploy both stacks and populate them with sample data, see the [Runbook](./docs/runbook.md).

## Repository Structure
```
.
├── README.md               # This file
├── cloudformation/
│   └── leet-sg-stack.yaml  # The main CloudFormation template
├── docs/
│   └── ...                 # Architectural diagrams and runbooks (TBD)
└── plans/
    ├── 01-build-phase.md   # Tasks for building the stack
    ├── 02-test-phase.md    # Tasks for testing and validation
    └── ...
```

Cloud Rewind Multi Account Demo
