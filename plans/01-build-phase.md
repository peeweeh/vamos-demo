# Build Phase: CloudFormation Development

*Goal: Develop CloudFormation templates for the Leet by Vamos demo environment.*

## Phase 1: Singapore Stack (`ap-southeast-1`) - COMPLETED

*CloudFormation Template: `cloudformation/leet-sg-stack.yaml`*
*Stack Name: `leet-sg-demo-stack`*

1.  **Networking:**
    *   [x] **VPC:** `leet-sg-vpc` (`10.11.0.0/16`).
    *   [x] **Subnets:** Public, App, DB tiers.
    *   [x] **Internet Gateway:** `leet-sg-igw`.
    *   [x] **Route Tables:** Public and Private.
2.  **Security:**
    *   [x] **Security Groups:** `leet-sg-sg-alb`, `leet-sg-sg-web`, `leet-sg-sg-db`.
3.  **Core Application (ALB → EC2 → RDS):**
    *   [x] **Application Load Balancer:** `leet-sg-alb`.
    *   [x] **ALB Target Group:** `leet-sg-tg-web`.
    *   [x] **EC2 Launch Template & ASG:** `leet-sg-lt-web`, `leet-sg-asg-web`.
    *   [x] **RDS MySQL Instance:** `leet-sg-rds`.
4.  **Auxiliary Services:**
    *   [x] **S3 Bucket:** `leet-sg-app-data`.
    *   [x] **DynamoDB Table:** `leet-sg-ddb`.
    *   [x] **SQS Queue:** `leet-sg-queue`.
    *   [x] **SNS Topic:** `leet-sg-topic`.
    *   [x] **Lambda Function:** `leet-sg-hello`.
5.  **Skipped Services:**
    *   [ ] **EFS File System:** `leet-sg-efs` - Skipped.
    *   [ ] **EKS Cluster:** `leet-sg-eks` - Skipped.

## Phase 2: Tokyo Resources (`ap-northeast-1`)

1.  **S3 Bucket - COMPLETED:**
    *   [x] **CloudFormation:** `cloudformation/tokyo-bucket-stack.yaml`.
    *   [x] **Stack Name:** `leet-jp-bucket-stack`.
    *   [x] **S3 Bucket:** Created successfully.

2.  **Restoration VPC - PENDING:**
    *   [ ] **Objective:** Create a minimal VPC for restoration demos.
    *   [ ] **CloudFormation:** `cloudformation/tokyo-vpc-stack.yaml`.
    *   [ ] **VPC:** `leet-jp-vpc-restore` (`10.31.0.0/16`).
    *   [ ] **Subnets:** One public subnet `leet-jp-public-a-restore` (`10.31.0.0/24`).
    *   [ ] **Internet Gateway & Routing:** Required for public access.
    *   [ ] **Security Group:** Default SG open for outbound, no inbound rules.
    *   [ ] **Deployment:** To be deployed as `leet-jp-vpc-stack`.

