# Build Phase: CloudFormation Development

*Goal: Develop a single, linted, and valid CloudFormation template (`cloudformation/leet-sg-stack.yaml`) based on the detailed specification.*

1.  **Networking:**
    *   [x] **VPC:** `leet-sg-vpc` (`10.11.0.0/16`, DNS hostnames enabled).
    *   [x] **Subnets:**
        *   Public: `leet-sg-public-a` (`10.11.0.0/24`), `leet-sg-public-b` (`10.11.1.0/24`).
        *   App: `leet-sg-app-a` (`10.11.10.0/24`), `leet-sg-app-b` (`10.11.11.0/24`).
        *   DB: `leet-sg-db-a` (`10.11.20.0/24`), `leet-sg-db-b` (`10.11.21.0/24`).
    *   [x] **Internet Gateway:** `leet-sg-igw` attached to the VPC.
    *   [x] **Route Tables:**
        *   `leet-sg-rt-public`: Default route `0.0.0.0/0` via IGW.
        *   `leet-sg-rt-app` & `leet-sg-rt-db`: Local routes only (no NAT).
2.  **Security:**
    *   [x] **Security Groups:**
        *   `leet-sg-sg-alb`: Ingress HTTP/80 from `0.0.0.0/0`.
        *   `leet-sg-sg-web`: Ingress HTTP/80 from `leet-sg-sg-alb`.
        *   `leet-sg-sg-db`: Ingress TCP/3306 from `leet-sg-sg-web`.
        *   `leet-sg-sg-efs`: Ingress NFS/2049 from `leet-sg-sg-web`.
3.  **Core Application (ALB → EC2 → RDS):**
    *   [ ] **Application Load Balancer:** `leet-sg-alb` (Public, HTTP/80).
    *   [ ] **ALB Target Group:** `leet-sg-tg-web` with health check on `/health`.
    *   [ ] **IAM Role:** `leet-sg-role-web` (Removed Instance Profile due to SCP).
    *   [ ] **EC2 Launch Template:** `leet-sg-lt-web` (Fixing AMI ID).
    *   [ ] **EC2 Auto Scaling Group:** `leet-sg-asg-web` (min=1, max=1) in public subnets.
    *   [ ] **RDS DB Subnet Group:** `leet-sg-db-subnetgrp` using `db-a`/`db-b` subnets.
    *   [ ] **RDS MySQL Instance:** `leet-sg-rds` (`db.t4g.micro`, 20GB gp3, Single-AZ).
4.  **Auxiliary Services:**
    *   [x] **S3 Bucket:** `leet-sg-app-data` with a `seed/` folder.
    *   [ ] **DynamoDB Table:** `leet-sg-ddb` (On-demand, PK: `id` string).
    *   [ ] **SQS Queue:** `leet-sg-queue` (Standard).
    *   [ ] **SNS Topic:** `leet-sg-topic`.
    *   [ ] **Lambda Function:** `leet-sg-hello` (128MB, no VPC).
    *   [ ] **EFS File System:** `leet-sg-efs` (One Zone in `app-a`, empty) - **SKIPPED**.
5.  **EKS Cluster (Parked):**
    *   [ ] **EKS Cluster:** `leet-sg-eks` (Public endpoint) - **SKIPPED**.
    *   [ ] **Managed Node Group:** `leet-sg-ng` (`t3.small`, desired=1, min=0, max=1) - **SKIPPED**.
6.  **Final Touches:**
    *   [ ] **Tagging:** Apply `Project=leet-dr-demo`, `Environment=dev`, `RegionRole=source-sg`, `Owner=P`, `CleanupBy=2025-11-30` to all resources.
    *   [ ] **Parameters:** Use CloudFormation parameters for secrets and configurable values.
    *   [ ] **Validation:** Run `cfn-lint` against the final template.
