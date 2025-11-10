# Singapore Cloud Rewind Demo Plan# Singapore Cloud Rewind Demo Plan



## 1. Objective## Objectives

Stand up a single, comprehensive CloudFormation stack in `ap-southeast-1` for a demo environment named "Leet." This stack will be fully discoverable by Cloud Rewind and include a representative three-tier application (ALB → EC2 → RDS) plus a variety of other supported AWS services to showcase broad recovery capabilities.- Stand up a demo-ready CloudFormation stack in `ap-southeast-1` that Cloud Rewind can fully inventory.

- Deliver a single template that deploys the complete topology: ALB → EC2 (nginx) → RDS plus auxiliary AWS services (S3, SQS, SNS, Lambda, DynamoDB, EFS, EKS baseline).

## 2. Scope & Deliverables- Prepare supporting documentation under `docs/` so demos are reproducible and hand-off friendly.



### In Scope:## Scope

*   **Infrastructure:** A single CloudFormation template deploying all resources in Singapore.- **In scope:** VPC and networking, security groups, ALB, launch template + ASG for nginx host, RDS MySQL instance, auxiliary managed services, optional Route 53 private zone, minimal EKS cluster. Repository structure updates (`plans/`, `docs/`).

*   **Services:** VPC, Subnets, IGW, Route Tables, Security Groups, ALB, EC2 Auto Scaling Group, RDS, S3, SQS, SNS, Lambda, DynamoDB, EFS, and a minimal EKS cluster.- **Out of scope:** Multi-region/Tokyo build, automated teardown, production hardening, cost optimization beyond current guardrails.

*   **Documentation:** Architectural diagrams, a runbook for deployment, and a README for the repository.

*   **Repository Structure:** All plans under `/plans`, all documentation under `/docs`.## Deliverables

- `cloudrewind-singapore.yaml` CloudFormation template with parameterization for core inputs (VPC CIDR, key pairs, DB creds, tags).

### Out of Scope:- `docs/architecture.md` showing logical/physical diagrams and service rationale.

*   Deployment to any region other than `ap-southeast-1` (Tokyo is reserved but not implemented).- `docs/runbook.md` covering deployment steps, verification checks, and cleanup guidance.

*   Automated testing or CI/CD pipelines.- `docs/readme.md` summarizing repo layout and demo usage.

*   Production-grade hardening, monitoring, or logging.- Recorded progress notes in `plans/` as implementation advances.



### Deliverables:## Workstreams & Tasks

1.  `cloudformation/leet-sg-stack.yaml`: The complete CloudFormation template.

2.  `docs/architecture.md`: Diagrams and descriptions of the infrastructure.### 1. Repository Prep

3.  `docs/runbook.md`: Step-by-step instructions for deploying and verifying the stack.- [ ] Create `plans/` (done) and `docs/` directories; stub `docs/readme.md` with structure placeholders.

4.  `README.md`: Updated root README explaining the project and repository structure.- [ ] Capture this plan in `plans/singapore-demo-plan.md` (done).

5.  `plans/progress.md`: A file to track task completion.

### 2. CloudFormation Authoring

## 3. Plan & Work Breakdown- [ ] Draft foundational networking resources (VPC, subnets, route tables, IGW attachments, tags).

- [ ] Layer security groups (ALB, web, DB, EFS) with least privilege rules matching spec.

### Phase 1: Foundation & Repository Setup- [ ] Define ALB, target group, listener, health checks; wire to ASG.

1.  **Create Directories:**- [ ] Build launch template with user data injecting S3/DB parameters via instance profile or SSM.

    *   [x] `plans/`- [ ] Add IAM role/profile permitting S3 reads and SSM access.

    *   [x] `docs/`- [ ] Model RDS subnet group and MySQL instance (single-AZ, gp3 20GB) with optional Secrets Manager reference.

    *   [ ] `cloudformation/`- [ ] Provision auxiliary services: S3 bucket with lifecycle rules, empty DynamoDB table, SQS queue, SNS topic, Lambda function + minimal handler, EFS file system + mount target, optional Route 53 private hosted zone.

2.  **Draft Initial Documents:**- [ ] Define EKS cluster + managed node group (desired=1, scale to 0 via update instructions) with subnet tagging.

    *   [x] This plan: `plans/singapore-demo-plan.md`- [ ] Attach stack-level tags (`Project`, `Environment`, `RegionRole`, `Owner`, `CleanupBy`).

    *   [ ] `plans/progress.md`

    *   [ ] `docs/architecture.md` (stub)### 3. Validation & Tooling

    *   [ ] `docs/runbook.md` (stub)- [ ] Run `cfn-lint` and `aws cloudformation validate-template` locally.

- [ ] Execute stack create in a test AWS account using env vars for credentials (exported per PRD).

### Phase 2: CloudFormation Development- [ ] Smoke test ALB endpoint: verify nginx landing page shows instance ID, S3 sample text, DB connectivity.

*Goal: Develop a single, linted, and valid CloudFormation template.*- [ ] Confirm auxiliary resources exist and are discoverable (AWS CLI describe calls or Cloud Rewind scan).



1.  **Networking:**### 4. Documentation & Handoff

    *   [ ] VPC, Subnets (Public, App, DB), IGW, and Route Tables.- [ ] Document deployment prerequisites (AWS CLI profile/env vars, key pair, parameter values) in `docs/runbook.md`.

2.  **Security:**- [ ] Add architecture diagrams (draw.io/png) and embed in `docs/architecture.md`.

    *   [ ] Security Groups for ALB, Web (EC2), DB (RDS), and EFS.- [ ] Update repo `docs/readme.md` explaining directory layout, how to deploy, and cleanup steps.

3.  **Core Application:**- [ ] Capture demo script highlights for Cloud Rewind showing discovery results.

    *   [ ] IAM Role for EC2 instance (S3 read, SSM).

    *   [ ] EC2 Launch Template with User Data for nginx setup.## Timeline (T-shirt estimates)

    *   [ ] EC2 Auto Scaling Group (min/max 1).- Day 0.5: Repository prep and networking scaffolding.

    *   [ ] Application Load Balancer (ALB) and Target Group.- Day 1: Core services (ALB, EC2, RDS) defined and validated.

    *   [ ] RDS DB Subnet Group and MySQL Instance.- Day 1.5: Auxiliary services + IAM + tagging complete.

4.  **Auxiliary Services:**- Day 2: Validation run, documentation drafts, demo rehearsal.

    *   [ ] S3 Bucket with `seed/` folder.

    *   [ ] DynamoDB Table.## Risks & Mitigations

    *   [ ] SQS Queue.- **Cost overruns** (ALB, RDS, EKS): enforce cleanup tag `CleanupBy`, document scale-to-zero steps.

    *   [ ] SNS Topic.- **Credential handling:** rely on environment variables & Parameter Store; avoid hardcoding secrets in template.

    *   [ ] Lambda Function.- **User data fragility:** add comments/tests to ensure S3 and RDS env vars present; bail out gracefully if missing.

    *   [ ] EFS File System and Mount Target.- **EKS complexity:** treat node group as optional parameter toggle; default to disabled if not required for demos.

5.  **EKS Cluster (Parked):**

    *   [ ] EKS Cluster (public endpoint).## Next Actions

    *   [ ] Managed Node Group (scaled to 0 after creation).1. Scaffold `docs/` directory with placeholder files.

6.  **Final Touches:**2. Begin CloudFormation template by codifying VPC and networking section.

    *   [ ] Add `Project`, `Environment`, and `CleanupBy` tags to all resources.3. Draft launch template user data script with parameter placeholders for S3 bucket and DB endpoint.

    *   [ ] Parameterize key values (e.g., DB password, KeyPair name).
    *   [ ] Validate template with `cfn-lint`.

### Phase 3: Deployment & Documentation
1.  **Deploy & Verify:**
    *   [ ] Deploy the stack to `ap-southeast-1` using AWS credentials from environment variables.
    *   [ ] Verify the ALB endpoint returns the nginx page with instance ID, S3 content, and DB status.
    *   [ ] Confirm all auxiliary services are created.
2.  **Complete Documentation:**
    *   [ ] Finalize `docs/architecture.md` with diagrams.
    *   [ ] Complete `docs/runbook.md` with deployment and verification steps.
    *   [ ] Update the main `README.md`.

## 4. Execution Strategy
*   **Build First, Test Second:** Focus on completing the full CloudFormation template before extensive testing.
*   **Track Progress:** Use `plans/progress.md` to mark tasks as complete.
*   **Credentials:** AWS credentials will be supplied via environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.) for all CLI operations.
