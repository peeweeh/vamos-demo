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
    *   [ ] **Web Application Files:**
        - Create `web/` folder in repository
        - Create `index.php` with form and database display logic
        - Create `db-config.php` for database connection parameters (templated)
        - Create `init-db.sql` for database schema initialization
        - Keep files simple and self-contained
    *   [ ] **S3 Upload Strategy:**
        - Store web files in the S3 bucket (`leet-sg-app-data`) under a `webapp/` prefix
        - Files will be uploaded before or during stack deployment
        - EC2 UserData will download files from S3 to `/usr/share/nginx/html/`
    *   [ ] **UserData Enhancement:** Update EC2 launch template to:
        - Install PHP-FPM, php-mysqlnd, nginx
        - Configure nginx to process PHP files
        - Download web application files from S3
        - Substitute RDS endpoint and credentials into db-config.php
        - Initialize database schema by running init-db.sql against RDS
        - Start/enable nginx and php-fpm services
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

1.  **S3 Bucket - COMBINED:**
    *   [x] **CloudFormation:** Combined into `cloudformation/tokyo-vpc-stack.yaml`.
    *   [x] **Stack Name:** Now part of `leet-jp-vpc-stack`.
    *   [x] **S3 Bucket:** Created successfully.

2.  **Restoration VPC - COMPLETED:**
    *   [x] **Objective:** Create a minimal VPC for restoration demos.
    *   [x] **CloudFormation:** `cloudformation/tokyo-vpc-stack.yaml`.
    *   [x] **VPC:** `leet-jp-vpc-restore` (`10.31.0.0/16`).
    *   [x] **Subnets:** One public subnet `leet-jp-public-a-restore` (`10.31.0.0/24`).
    *   [x] **Internet Gateway & Routing:** Required for public access.
    *   [x] **Security Group:** Default SG open for outbound, no inbound rules.
    *   [x] **S3 Bucket:** `vamos-leet-tokyo-bucket-${AWS::AccountId}` (combined into same stack).
    *   [x] **Deployment:** To be deployed as `leet-jp-vpc-stack`.

