# Architecture: Leet by Vamos - Singapore Demo Stack

This document describes the architecture of the "Leet" demo stack deployed in the `ap-southeast-1` region.

## Overview
The stack is designed to be a representative, multi-tier application environment that can be fully discovered and managed by Cloud Rewind. It consists of a core web application and several auxiliary serverless services. All resources are tagged with `Project=leet-dr-demo`.

## Network Topology
- **VPC (`leet-sg-vpc`):** A single VPC with a `10.11.0.0/16` CIDR block.
- **Subnets:** The VPC is divided into three layers across two Availability Zones:
    - **Public Subnets:** `10.11.0.0/24` (AZ-a) and `10.11.1.0/24` (AZ-b). These subnets have a route to the Internet Gateway and are used for public-facing resources like the ALB and EC2 instances.
    - **Application Subnets:** `10.11.10.0/24` (AZ-a) and `10.11.11.0/24` (AZ-b). These are private subnets intended for application-layer resources (not currently used).
    - **Database Subnets:** `10.11.20.0/24` (AZ-a) and `10.11.21.0/24` (AZ-b). These are private subnets for the RDS database.
- **Internet Gateway (`leet-sg-igw`):** Provides internet access for the public subnets.
- **Route Tables:** A public route table directs traffic to the IGW, while private route tables only allow local VPC traffic.

## Core Application
The core of the demo is a classic three-tier web application.

![Architecture Diagram](https://...placeholder-for-diagram.../architecture.png)

1.  **Application Load Balancer (`leet-sg-alb`):**
    - An internet-facing ALB listens for HTTP traffic on port 80.
    - It distributes incoming requests to the EC2 instances in the web tier.

2.  **Web Tier (EC2):**
    - **Auto Scaling Group (`leet-sg-asg-web`):** Manages a single `t3.micro` EC2 instance.
    - **Launch Template (`leet-sg-lt-web`):** Defines the EC2 instance configuration, including the Amazon Linux 2023 AMI and user data to install and configure an nginx web server.
    - **Security Group (`leet-sg-sg-web`):** Allows inbound traffic on port 80 only from the ALB.

3.  **Database Tier (RDS):**
    - **RDS MySQL Instance (`leet-sg-rds`):** A `db.t4g.micro` MySQL database instance running in a single AZ.
    - **DB Subnet Group (`leet-sg-db-subnetgrp`):** Places the RDS instance in the private database subnets.
    - **Security Group (`leet-sg-sg-db`):** Allows inbound traffic on port 3306 only from the web tier security group.

## Auxiliary Services
To demonstrate broad service coverage for Cloud Rewind, the following serverless and managed services are also deployed:

- **Amazon S3 (`leet-sg-app-data-<ACCOUNT_ID>`):** A private S3 bucket for storing application assets and data.
- **Amazon DynamoDB (`leet-sg-ddb`):** A simple, on-demand DynamoDB table with a single string primary key (`id`).
- **Amazon SQS (`leet-sg-queue`):** A standard SQS queue for messaging.
- **Amazon SNS (`leet-sg-topic`):** An SNS topic for pub/sub notifications.
- **AWS Lambda (`leet-sg-hello`):** A simple Python 3.9 function that can be invoked to demonstrate serverless function support.

## Skipped Resources
For simplicity and to avoid potential permission issues, the following resources from the original specification were not deployed:
- **Amazon EFS:** The Elastic File System was skipped.
- **Amazon EKS:** The Elastic Kubernetes Service cluster was skipped.
