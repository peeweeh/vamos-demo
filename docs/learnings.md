# Key Learnings from the "Leet by Vamos" Deployment

This document summarizes the key technical takeaways and lessons learned during the iterative development and deployment of the CloudFormation stack.

## 1. Service Control Policies (SCPs) Can Block Deployments
The most significant hurdle was an AWS Service Control Policy (SCP) that explicitly denied the `iam:CreateInstanceProfile` action.
- **Impact:** This prevented us from attaching an IAM Role to the EC2 instance via an instance profile, which was needed for the application to access the S3 bucket.
- **Lesson:** Always be aware of the SCPs in the target environment. They are a common security guardrail in enterprise accounts and can override permissions granted by IAM policies. We had to adapt by removing the feature, highlighting that real-world deployments must sometimes compromise on design to fit security constraints.

## 2. CloudFormation Requires Precision
We encountered several validation errors that served as good reminders of CloudFormation's strictness.
- **Resource Naming:** The initial error with Application Load Balancer resources (`AWS::EC2::LoadBalancer`) was resolved by using the correct, modern types (`AWS::ElasticLoadBalancingV2::LoadBalancer`).
- **IAM Capabilities:** Deploying a stack with named IAM roles (`RoleName: ...`) requires acknowledging this with `CAPABILITY_NAMED_IAM`, not just `CAPABILITY_IAM`.
- **AMI IDs:** A hardcoded AMI ID (`ami-0c55b159cbfafe1f0`) caused a validation failure. This was fixed by using a dynamic SSM parameter lookup (`{{resolve:ssm:...}}`), which is a more resilient best practice.

## 3. Iterative Debugging is Essential
The deployment process was not a single shot but a series of attempts, failures, and fixes.
- **`describe-stack-events`:** This was our primary tool for understanding why a deployment failed.
- **Disabling Rollback:** Using `--disable-rollback` was useful for preserving the state of a failed stack, allowing us to inspect the resources that were created before the failure occurred.

## 4. Automation and Documentation are Worth the Effort
- **`runbook.sh`:** Manually populating data is tedious and error-prone. Creating a simple shell script to seed the S3 bucket, DynamoDB table, SQS queue, and SNS topic made the process repeatable and reliable.
- **Living Documentation:** The `README.md`, `architecture.md`, and plans were continuously updated to reflect the final state of the project, including the compromises and workarounds. This ensures that anyone joining the project understands not just the "what" but also the "why."
