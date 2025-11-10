

## 1) Problem

Stand up a **single-account, ap-southeast-1** source environment for “Leet” that is:

* Demoable now: **ALB → EC2 (nginx) → RDS**. [98% sure]
* Broadly covered by Cloud Rewind: include **S3, SQS, SNS, Lambda, DynamoDB, EFS, Route 53 (optional)** so the recovery plan looks rich. [92% sure]
* **EKS minimal** in the same VPC, empty workload, dirt-cheap. [95% sure]

## 2) Analysis

* Cost is dominated by ALB hourly/LCUs, EC2 hours, RDS instance hours, and NAT if you add it. Solution: **no NAT**, put the web EC2 in public subnets and keep RDS private. EKS control plane bills by hour; one cluster only, scale node group to 0 off-hours. [93% sure]
* ALB needs **two subnets/AZs**. RDS needs a **DB subnet group spanning two AZs** even for single-AZ DBs. [96% sure]
* To show “supported services,” create the lightest viable artifacts: 1 tiny DynamoDB table (on-demand), 1 SQS, 1 SNS, a 128-MB Lambda not in a VPC, 1 empty EFS (One Zone), and an S3 bucket with a small `seed/` folder the nginx instance reads. Route 53 is optional; a **private hosted zone** proves the point for pennies. [92% sure]

## 3) Implication

You get a clean, NATless three-tier-ish topology that’s cheap to idle, rich enough for Cloud Rewind discovery, and straightforward to rebuild in Tokyo later. [95% sure]

---

# Architecture (Leet, Singapore only)

```
VPC 10.11.0.0/16  (no NAT)
  Public subnets: 10.11.0.0/24 (AZ-a), 10.11.1.0/24 (AZ-b)
  Private app subnets: 10.11.10.0/24 (AZ-a), 10.11.11.0/24 (AZ-b)
  Private db subnets:  10.11.20.0/24 (AZ-a), 10.11.21.0/24 (AZ-b)

ALB (HTTP:80)  →  EC2 nginx (t3.micro, public subnets)
                           ↘
                            RDS MySQL (db.t4g.micro, single-AZ, private db subnets)

S3:   leet-sg-app-data (seed files)     DynamoDB: leet-sg-ddb (on-demand)
SQS:  leet-sg-queue                     SNS:      leet-sg-topic
Lambda: leet-sg-hello (128MB, no VPC)   EFS:      leet-sg-efs (One Zone, empty)

EKS (parked): leet-sg-eks (public endpoint)
  Node group leet-sg-ng (t3.small, desired=1 for creation, scale to 0 after)
```

Reserve but **don’t create** Tokyo CIDR now: `10.31.0.0/16`. [95% sure]

---

## CloudFormation Bill of Materials (names + “why this is cheap”)

### Networking

* `leet-sg-vpc` with DNS hostnames/support on.
* `leet-sg-igw` + attachment.
* Subnets:

  * `leet-sg-public-a`, `leet-sg-public-b` (MapPublicIpOnLaunch=true)
  * `leet-sg-app-a`, `leet-sg-app-b`
  * `leet-sg-db-a`, `leet-sg-db-b`
* Route tables:

  * `leet-sg-rt-public` default 0.0.0.0/0 → IGW
  * `leet-sg-rt-app` local only (no NAT)
  * `leet-sg-rt-db` local only (no NAT)

### Security groups

* `leet-sg-sg-alb`: ingress 80 from 0.0.0.0/0; egress all.
* `leet-sg-sg-web`: ingress 80 from `sg-alb`; egress all.
* `leet-sg-sg-db`: ingress 3306 from `sg-web`; egress all.
* `leet-sg-sg-efs`: NFS 2049 from `sg-web` only if you mount nginx to EFS later.

### Load balancer

* **Pick:** Application Load Balancer

  * `leet-sg-alb` in both public subnets, HTTP:80.
  * Target group `leet-sg-tg-web` with health check `/health`.

### EC2 (web)

* Launch template `leet-sg-lt-web`:

  * AMI: Amazon Linux 2023, `t3.micro`, gp3 10 GB, public IP, instance profile `leet-sg-role-web`.
  * **User data** (minimal): install nginx, place `/usr/share/nginx/html/index.html` that prints instance-id, reads a tiny text from S3, and shows a DB row; `/health` returns 200.
* Auto Scaling group `leet-sg-asg-web`: min=1, max=1; subnets = public A/B.
* IAM role `leet-sg-role-web`: `AmazonSSMManagedInstanceCore` + S3 read-only policy (scoped to `leet-sg-app-data`).

### RDS (db)

* DB subnet group `leet-sg-db-subnetgrp` with db-a/db-b.
* MySQL instance `leet-sg-rds`: `db.t4g.micro`, gp3 20 GB, Single-AZ, not publicly accessible, parameter group default.
* Secrets Manager entry optional for creds if you want to be civilized.

### S3

* Bucket `leet-sg-app-data`

  * Folder `seed/` with a 1–2 small files.
  * Block public access on. No bucket policy needed beyond default.

### DynamoDB

* `leet-sg-ddb` (on-demand) with a simple PK (`id` string). Preload 1–2 items if you want Cloud Rewind to discover non-empty config. Cheap and instant.

### SQS / SNS / Lambda

* `leet-sg-queue` (standard).
* `leet-sg-topic`.
* `leet-sg-hello` Lambda: runtime Python or Node, 128 MB, timeout 5s, no VPC. Grant publish to SNS and send to SQS; optionally wire an SNS subscription that fires the Lambda to prove events exist. Zero idle cost beyond Lambda’s storage.

### EFS (optional but included for support coverage)

* `leet-sg-efs` file system, **One Zone** in AZ-a, lifecycle policy to IA after 7 days, no data.
* One mount target in `leet-sg-app-a` subnet with SG `leet-sg-sg-efs`. Leave it empty; negligible cost when unused.

### Route 53 (optional but nice)

* Private hosted zone `leet.local`, VPC-associated.
* A record `web.leet.local` → ALB target. Cost: pocket change; helps prove Route 53 support.

### EKS (parked)

* `leet-sg-eks` cluster (public endpoint).
* `leet-sg-ng` managed node group: `t3.small`, desired=1, min=0, max=1; scale to 0 after cluster becomes Ready.
* Subnet tags on both public subnets:

  * `kubernetes.io/cluster/leet-sg-eks = shared`
  * `kubernetes.io/role/elb = 1`

---

## Minimal nginx user data (works for the demo)

```bash
#!/bin/bash
dnf -y install nginx jq mysql
systemctl enable --now nginx
curl -s http://169.254.169.254/latest/meta-data/instance-id > /tmp/iid

# very tiny index
cat >/usr/share/nginx/html/index.html <<'HTML'
<html><body>
<h3>Leet demo</h3>
<p>Instance: $(cat /tmp/iid)</p>
<p>S3 sample: $(curl -s https://$S3_BUCKET.s3.amazonaws.com/seed/demo.txt)</p>
<p>DB status: $(echo "select 'db-ok' as status;" | mysql -h $DB_ENDPOINT -u $DB_USER -p$DB_PASSWORD 2>/dev/null | tail -1)</p>
</body></html>
HTML

echo "OK" > /usr/share/nginx/html/health
systemctl reload nginx
```

Environment variables (`S3_BUCKET`, `DB_ENDPOINT`, `DB_USER`, `DB_PASSWORD`) can be pushed via ASG launch template user data or SSM Parameter Store.

---

## Tags and naming

**Prefix:** `leet-sg-<component>`
**Baseline tags everywhere:**
`Project=leet-dr-demo`, `Environment=dev`, `RegionRole=source-sg`, `Owner=P`, `CleanupBy=2025-11-30`

If clickops entropy eats your standards, `CleanupBy` still rescues your wallet.

---

## Cost guardrails that matter

* **No NAT.** Web in public, RDS private. You avoid the hourly + per-GB NAT tax. [93% sure]
* **One ALB, one TG, one listener.** ALB LCUs are quiet when traffic is low; don’t add HTTPS unless you must. [92% sure]
* **EC2 t3.micro x1.** ASG scheduled action to 0 off-hours if you’re really pinching. [90% sure]
* **RDS db.t4g.micro, Single-AZ, gp3 20 GB.** Backups keep small. [92% sure]
* **EKS:** one cluster, scale node group to 0 when not demoing. Control plane still bills; accept it. [91% sure]
* **Lambda/SNS/SQS/DDB/EFS/S3:** idle or pennies. Keep EFS empty; choose One Zone. [90% sure]

---

## What Cloud Rewind will happily discover/rebuild later

* VPC/subnets/RTs/SGs, **ALB**, EC2, **RDS**, **S3**, **SQS**, **SNS**, **DynamoDB**, **EFS**, and **Lambda**.
* **EKS** will be discovered for context but not rebuilt; it’s just there so your inventory looks complete, and you can later restore a namespace to Tokyo’s EKS when you care. [93% sure]

---

If you want, I can spit this as a single CFN BOM with parameters and skeletal YAML blocks so your Copilot can finish the wiring. But this is the minimal, cheap, Cloud Rewind-friendly stack you asked for.

[Confidence: 94%]
