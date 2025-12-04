###Task 4 - Billing & Free Tier Cost Monitoring
============================================

Importance of Cost Monitoring
-----------------------------

### Why Cost Monitoring is Critical for Beginners

1.  **Prevent Surprise Bills:** A single misconfigured resource can cost hundreds/thousands of dollars.
2.  **Budget Control:** Stay within AWS Free Tier limits.
3.  **Resource Optimization:** Find unused resources and delete them.
4.  **Vendor Lock-in Prevention:** Avoid hidden costs early.
5.  **Best Practice:** AWS recommends enabling billing alerts immediately.
6.  **Compliance:** Helps with audits and documentation.

### Common Causes of Unexpected AWS Bills

Cause

Impact

Monthly Cost

**Large Instance Running Unused**

m5.2xlarge left running 24/7

$700-900

**NAT Gateway**

$0.045/GB. 100GB = $4.50

$4.50-100+

**Data Transfer Out**

Cross-region / Internet

$20-500+

**Unattached EBS Volumes**

$0.10 per GB

$5-50+

**Elastic IP (Unassociated)**

$0.005/hr

$36+

**RDS Multi-AZ**

Replica cost same as primary

$50-400+

**Managed Services**

DynamoDB, ElastiCache

$100-1000+

**API Gateway Calls**

$3.50 per million

$50-500+

**Accidental Resource Creation**

Auto Scaling issues

$500+

Implementation Strategy
-----------------------

This Terraform setup deploys a 3-layer cost monitoring system:

### Layer 1: CloudWatch Billing Alarm

*   Tracks `EstimatedCharges`
*   Triggers SNS notification
*   Region: **us-east-1**

### Layer 2: AWS Budgets

*   Monthly budget with alerts
*   Free Tier usage alerts
*   Forecasting-based alerts

### Layer 3: CloudWatch Dashboard

*   Graphs of estimated charges
*   Historical data

Cost Setup
----------

### Currency Conversion (₹ → USD)

₹100 / 83 = ~$1.20 USD

*   **Threshold USD:** $1.20
*   **Monthly Budget:** $20
*   **Free Tier Alerts:** $0

Deployment Instructions
-----------------------

cd 4\_Billing\_Alerts
terraform init
terraform plan \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "threshold\_usd=1.2" \\
  -var "monthly\_budget\_limit=20" \\
  -var "email\_address=your-email@example.com"

terraform apply \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "threshold\_usd=1.2" \\
  -var "monthly\_budget\_limit=20" \\
  -var "email\_address=your-email@example.com"

**IMPORTANT:** After applying, open your email and confirm SNS subscription.

Screenshots to Capture
----------------------

1.  CloudWatch Billing Alarm
2.  SNS Topic & Subscription
3.  AWS Budgets - Monthly Budget
4.  AWS Budgets - Free Tier Budget
5.  Billing Dashboard
6.  Estimated Charges (Bills Page)

Monitoring Best Practices
-------------------------

*   Use multiple thresholds
*   Review bills weekly
*   Investigate immediately when alert triggers
*   Use Free Tier limits smartly

terraform destroy \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "threshold\_usd=1.2" \\
  -var "monthly\_budget\_limit=20" \\
  -var "email\_address=your-email@example.com"

cd ../3\_HA\_AutoScaling && terraform destroy ...
cd ../2\_EC2\_Static\_Website && terraform destroy ...
cd ../1\_Networking\_VPC && terraform destroy ...

Key Features Implemented
------------------------

*   CloudWatch Billing Alarm
*   AWS Budgets
*   Free Tier usage monitoring
*   Dashboard
*   Email Alerts via SNS
*   Multi-threshold alerting