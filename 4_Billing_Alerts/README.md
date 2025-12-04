
# Task 4 - Billing & Free Tier Cost Monitoring

## Importance of Cost Monitoring

### Why Cost Monitoring is Critical for Beginners

1. **Prevent Surprise Bills**: AWS free tier covers limited usage. Without monitoring, a single misconfigured resource can cost hundreds/thousands monthly
2. **Budget Control**: Enables proactive cost management before reaching critical limits
3. **Resource Optimization**: Identify unused resources and eliminate waste
4. **Vendor Lock-in Prevention**: Early cost awareness prevents expensive lock-in scenarios
5. **Best Practice**: AWS recommends immediate cost controls as first security layer
6. **Compliance**: Demonstrate cost controls to stakeholders and auditors

### Common Causes of Unexpected AWS Bills

| Cause | Impact | Monthly Cost |
|-------|--------|--------------|
| **Large Instance Running Unused** | On-demand m5.2xlarge left running 24/7 | $700-900 |
| **NAT Gateway** | Data egress through NAT: $0.045/GB = 100GB costs $4.50 | $4.50-100+ |
| **Data Transfer Out** | Inter-region or internet egress at $0.02-0.09/GB | $20-500+ |
| **Unattached EBS Volumes** | $0.10/GB-month for forgotten snapshots/volumes | $5-50+ |
| **Elastic IP (Unassociated)** | $0.005/hour for unused IPs = $36/month each | $36+ per IP |
| **RDS Multi-AZ** | Standby replica costs same as primary | $50-400+ |
| **Managed Services** | DynamoDB, ElastiCache, etc. with on-demand pricing | $100-1000+ |
| **API Gateway Calls** | $3.50 per million calls = high-volume apps | $50-500+ |
| **Accidental Resource Creation** | Auto Scaling creating uncontrolled instances | $500+ |

## Implementation Strategy

This Terraform configuration implements a **3-layer** cost control system:

### Layer 1: CloudWatch Billing Alarm
- Monitors `EstimatedCharges` metric in AWS/Billing namespace
- Triggers SNS notification when spending exceeds threshold
- Real-time alerts every 6 hours
- Region: us-east-1 (only region with billing metrics)

### Layer 2: AWS Budgets
- **Monthly Budget**: Tracks EC2 spending with 80% and 100% thresholds
- **Free Tier Budget**: Alerts on ANY usage beyond free tier limits
- Forecasting-based alerts for early warning
- Daily notification frequency

### Layer 3: CloudWatch Dashboard
- Visual representation of estimated charges
- Historical trend analysis
- Integration with other monitoring metrics

## Cost Calculation & Setup

### Currency Conversion (₹ to USD)
```
₹100 / 83 (approximate INR to USD) = ~$1.20
Use threshold_usd = 1.2
```

For this assessment:
- **Threshold USD**: $1.20 (equivalent to ₹100)
- **Monthly Budget**: $20 (recommended for free tier testing)
- **Free Tier Alert**: $0 (alert on any overage)

## Deployment Instructions

```bash
cd 4_Billing_Alerts
terraform init
terraform plan \
  -var "prefix=Harsh_Gupta_" \
  -var "threshold_usd=1.2" \
  -var "monthly_budget_limit=20" \
  -var "email_address=your-email@example.com"

terraform apply \
   -var "prefix=Harsh_Gupta_" \
  -var "threshold_usd=1.2" \
  -var "monthly_budget_limit=20" \
  -var "email_address=your-email@example.com"
```

**Important**: After `terraform apply`, check your email and **confirm the SNS subscription** to enable notifications.

## Screenshots to Capture

1. **CloudWatch Billing Alarm**
   - Alarm name: `Harsh_Gupta_billing-alarm-usd`
   - Metric: EstimatedCharges
   - Threshold: USD 1.2
   - State (OK/ALARM)

2. **SNS Topic & Subscription**
   - Topic name: `Harsh_Gupta_billing-alerts`
   - Subscription status (Confirmed)
   - Endpoint email address

3. **AWS Budgets - Monthly Budget**
   - Budget name: `Harsh_Gupta_monthly-budget`
   - Budget limit: $20
   - Current spending vs limit
   - Alert thresholds (80%, 100%)

4. **AWS Budgets - Free Tier Budget**
   - Free tier usage tracking
   - Services with free tier limits (EC2, S3, etc.)
   - Current vs free limit

5. **Billing Dashboard**
   - CloudWatch dashboard showing estimated charges
   - Historical trend (last 30 days)

6. **Estimated Charges Page**
   - AWS Console → Billing & Cost Management → Bills
   - Show current month's estimated charges
   - Service breakdown (EC2, NAT Gateway, etc.)

## Monitoring Best Practices

1. **Set Multiple Thresholds**:
   - Alert 1: $1.20 (early warning)
   - Budget: $20 (hard limit)
   - Free Tier: $0 (overage protection)

2. **Review Regularly**:
   - Weekly: Check CloudWatch dashboard
   - Monthly: Review Cost Explorer
   - Quarterly: Analyze usage patterns

3. **Act on Alerts**:
   - Investigate immediately upon alert
   - Check for new instances, data transfers, etc.
   - Scale down or delete unnecessary resources

4. **Optimize Costs**:
   - Use Free Tier wisely (12 months for many services)
   - Schedule instances with Lambda if temporary
   - Use Reserved Instances/Savings Plans for predictable loads
   - Enable S3 lifecycle policies
   - Monitor data egress carefully

## Cost Estimation for This Assessment

| Resource | Free Tier | Cost/Month |
|----------|-----------|-----------|
| 4 t2.micro instances | Yes (750 hrs) | $0 (with rotation) |
| ALB | No | ~$16 + data processing |
| NAT Gateway | No | $32 (1 per AZ) + egress |
| EBS volumes | Yes (30GB) | $0 if ≤ 30GB |
| Data transfer | Yes (1GB) | $0 if ≤ 1GB out |
| CloudWatch | Limited free tier | ~$0.50 |
| **Total Estimated** | | **$48-65** (if left running 24/7) |

**To minimize costs**:
- Delete resources after testing
- Test for short durations only
- Use Free Tier limits wisely

## Cleanup

```bash
# Delete all monitoring resources
terraform destroy \
  -var "prefix=Harsh_Gupta_" \
  -var "threshold_usd=1.2" \
  -var "monthly_budget_limit=20" \
  -var "email_address=your-email@example.com"# Then delete infrastructure from Tasks 1-3
cd ../3_HA_AutoScaling && terraform destroy ...
cd ../2_EC2_Static_Website && terraform destroy ...
cd ../1_Networking_VPC && terraform destroy ...
```

## Key Features Implemented

✅ CloudWatch billing alarm with SNS notifications  
✅ AWS Budgets monthly tracking  
✅ Free Tier usage alerting  
✅ CloudWatch dashboard for visualization  
✅ Email-based alerts  
✅ Multi-threshold approach  
✅ Cost analysis documentation  
✅ Best practices guide
