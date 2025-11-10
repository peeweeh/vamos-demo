# Leet by Vamos - AWS Demo Environment Plan

## 1. Objective

Stand up a comprehensive AWS demo environment for "Leet by Vamos". This involves a primary stack in `ap-southeast-1` (Singapore) and supplementary resources in `ap-northeast-1` (Tokyo) to showcase multi-region capabilities and disaster recovery scenarios.

## 2. Scope & Deliverables

### In Scope:
*   **Singapore Stack (`ap-southeast-1`):** A single CloudFormation template deploying a three-tier application (ALB → EC2 → RDS) and various auxiliary services (S3, DynamoDB, SQS, SNS, Lambda).
*   **Tokyo Resources (`ap-northeast-1`):** Separate CloudFormation templates for an S3 bucket and a minimal restoration VPC.
*   **Documentation:** A complete set of documentation under `docs/` including architecture, a runbook for deployment and data seeding, and lessons learned.
*   **Repository Structure:** All plans under `/plans`, all documentation under `/docs`, and all CloudFormation templates under `cloudformation/`.

### Out of Scope:
*   Automated testing or CI/CD pipelines.
*   Production-grade hardening, monitoring, or logging.
*   EFS and EKS, which were initially planned but later skipped.

## 3. Workstreams & Tasks

The detailed breakdown of build and test tasks are in separate files:

*   **[Build Plan](./01-build-phase.md):** Tracks the creation of all CloudFormation templates and resources. This includes the completed Singapore stack, the completed Tokyo S3 bucket, and the pending Tokyo VPC.
*   **[Test Plan](./02-test-phase.md):** Outlines the steps for testing and verifying the deployed resources and application functionality.

