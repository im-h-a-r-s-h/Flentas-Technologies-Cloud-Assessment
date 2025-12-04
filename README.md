# AWS Technical Assessment - Harsh Gupta

## Overview

This repository contains a complete AWS infrastructure implementation demonstrating enterprise-grade cloud architecture design, security best practices, and infrastructure-as-code (IaC) principles. The assessment covers five key AWS domains: networking, compute, high availability, cost monitoring, and scalable architecture design.

**Repository Structure**:
- `1_Networking_VPC/` - VPC design with subnets, gateways, and NAT
- `2_EC2_Static_Website/` - Hardened EC2 instance with Nginx
- `3_HA_AutoScaling/` - High availability setup with ALB and ASG
- `4_Billing_Alerts/` - Cost monitoring with CloudWatch and Budgets
- `5_Architecture_Diagram/` - Scalable architecture design for 10,000 users

---

## Task 1: Networking & Subnetting (AWS VPC Setup)

### Approach
Designed a multi-tier VPC architecture with public and private subnets across two availability zones for high availability and security isolation. The VPC follows AWS best practices with appropriate CIDR planning for future expansion.

### CIDR Planning
```
VPC CIDR: 10.0.0.0/16 (65,536 IPs)
├── Public Subnet 1: 10.0.0.0/24 in ap-south-1a (256 IPs)
├── Public Subnet 2: 10.0.1.0/24 in ap-south-1b (256 IPs)
├── Private Subnet 1: 10.0.10.0/24 in ap-south-1a (256 IPs)
└── Private Subnet 2: 10.0.11.0/24 in ap-south-1b (256 IPs)
```

### Why These Ranges?
- **10.0.0.0/16**: Standard RFC1918 private range, scalable for multi-tier deployments
- **Public Subnets (0, 1)**: First octet range for intuitive identification
- **Private Subnets (10, 11)**: Separated to avoid overlaps, easy to distinguish
- **/24 Subnet Mask**: Provides 254 usable IPs per subnet, appropriate for free tier testing

### Key Components
- **Internet Gateway (IGW)**: Enables public subnet internet connectivity
- **NAT Gateway**: Allows private subnet instances secure outbound internet access
- **Route Tables**: Public (→IGW), Private (→NAT Gateway)
- **Security**: Isolation between tiers via subnet design and route tables

### Deployment
```bash
cd 1_Networking_VPC
terraform init
terraform plan -var "prefix=Harsh_Gupta_"
terraform apply -var "prefix=Harsh_Gupta_"
```

### Outputs Needed
- VPC ID and CIDR range
- All 4 subnet IDs and CIDR ranges
- NAT Gateway ID and public IP
- Internet Gateway ID

---

## Task 2: EC2 Static Website Hosting (Resume)

### Approach
Deployed a production-ready, hardened EC2 instance with professional resume website using Nginx. Implemented multi-layered security hardening including encrypted storage, restricted security groups, automatic updates, and security headers.

### Architecture
```
┌─────────────────────────┐
│  Public Internet         │
└────────────┬────────────┘
             ↓
    ┌────────────────┐
    │  Security Group│
    │ ✓ HTTP (80)    │
    │ ✓ HTTPS (443)  │
    │ ✓ SSH (22)     │
    └────────────┬───┘
                 ↓
    ┌────────────────────┐
    │  t2.micro EC2      │
    │  - Ubuntu 20.04    │
    │  - Nginx Server    │
    │  - Resume Website  │
    │  - IAM Role        │
    │  - Encrypted EBS   │
    └────────────┬───────┘
                 ↓
    ┌────────────────────┐
    │  Professional      │
    │  Resume HTML       │
    │  with Styling      │
    └────────────────────┘
```

### Security Hardening Measures
1. **Network Security**: Restrictive security group, only necessary ports
2. **OS Security**: Automatic updates, UFW firewall, minimal services
3. **Encryption**: Encrypted EBS volume (AES-256)
4. **IAM**: Role-based access for AWS services
5. **Web Security**: Security headers, proper file permissions

### Deployment
```bash
cd 2_EC2_Static_Website
terraform init
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_id=subnet-xxxxx"
```

---

## Task 3: High Availability + Auto Scaling

### Approach
Implemented a production-grade highly available architecture with multi-AZ deployment, automatic scaling, and health-based load balancing. Supports 10,000+ concurrent users.

### Architecture Overview
```
Internet → ALB (Public Subnets)
           ↓
    Target Group (port 80)
           ↓
    ASG (Min:2, Max:3)
           ↓
    EC2 Instances (Private Subnets)
    - ap-south-1a
    - ap-south-1b
```

### Key Components
- **ALB**: Internet-facing, health checks, sticky sessions
- **Target Group**: Port 80, health check every 30s
- **ASG**: 2-3 instances across 2 AZs
- **Scaling**: CPU-based (>70% scale up, <30% scale down)
- **Security**: Cross-group isolation, encrypted volumes

### Deployment
```bash
cd 3_HA_AutoScaling
terraform init
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-1\",\"subnet-2\"]" \
  -var "private_subnet_ids=[\"subnet-3\",\"subnet-4\"]"
```

---

## Task 4: Billing & Free Tier Cost Monitoring

### Approach
Implemented a comprehensive 3-layer cost control system combining CloudWatch alarms, AWS Budgets, and SNS notifications to prevent unexpected bills.

### Why Cost Monitoring Matters
- **Prevent Surprise Bills**: Single misconfigured resource = $100s monthly
- **Budget Control**: Proactive management before critical limits
- **Resource Optimization**: Identify and eliminate waste
- **Best Practice**: AWS recommends immediate cost controls
- **Free Tier Protection**: Ensure usage stays within limits

### Common Cost Culprits
| Resource | Monthly Cost |
|----------|--------------|
| m5.2xlarge instance 24/7 | $900 |
| NAT Gateway (100GB egress) | $100 |
| Unassociated Elastic IPs | $36 each |
| RDS Multi-AZ | $200-400 |

### Implementation Layers
1. **CloudWatch Alarm**: Monitors EstimatedCharges, threshold ₹100 (~$1.20)
2. **AWS Budgets**: Monthly $20 budget with 80%/100% alerts
3. **CloudWatch Dashboard**: Visual representation and trends

### Deployment
```bash
cd 4_Billing_Alerts
terraform init
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "threshold_usd=1.2" \
  -var "email_address=your-email@example.com"
```

**Note**: Confirm SNS subscription via email.

### Cost Estimation (if running 24/7)
- EC2 (4 t2.micro): Free (free tier)
- ALB: ~$16 + data processing
- NAT Gateway: $32 + egress charges
- **Total**: $400-500 monthly

---

## Task 5: Architecture Diagram (10,000 Concurrent Users)

### Architecture Overview
Designed highly scalable, fault-tolerant architecture supporting 10,000+ concurrent users with automatic scaling, multi-layered security, and comprehensive monitoring.

### Core Components
1. **Edge & CDN**: CloudFront + Route 53
2. **Security**: WAF + Shield + Security Groups + NACLs
3. **Load Balancing**: Application Load Balancer (ALB)
4. **Compute**: Auto Scaling Group (20+ instances)
5. **Database**: Aurora PostgreSQL Multi-AZ + Read Replicas
6. **Caching**: ElastiCache Redis cluster
7. **Storage**: S3 with lifecycle policies
8. **Monitoring**: CloudWatch + X-Ray + CloudTrail

### Traffic Flow
```
User → Route 53 → CloudFront → ALB → ASG Instances → Aurora + ElastiCache
```

### Capacity Planning
- **Concurrency**: 10,000 users = 10,000 req/sec
- **Instances**: ~20 t2.xlarge (500 req/sec each)
- **Database**: Aurora primary + 2 read replicas
- **Cache**: Redis cluster-mode

### Security Layers
- **Layer 1**: DDoS protection (Shield + WAF)
- **Layer 2**: Network isolation (Security Groups, NACLs)
- **Layer 3**: Encryption (EBS, RDS, S3, TLS transit)
- **Layer 4**: Access control (IAM, Secrets Manager)
- **Layer 5**: Audit trail (CloudTrail, VPC Flow Logs)

### High Availability
- Multi-AZ across 2+ zones
- Automatic instance failure recovery
- RDS failover <1 minute
- Database read replicas
- CloudFront global distribution
- Cross-region backups

### Cost (Production)
- **Estimated**: $700-1400/month
- **Optimization**: Reserved instances (40-60% savings), Spot instances (70-90%)

---

## Terraform Best Practices Implemented

✅ Modular design (separate folders)  
✅ Variable management with defaults  
✅ Resource tagging with prefix  
✅ Encrypted storage  
✅ IAM roles and least privilege  
✅ Security groups isolation  
✅ CloudWatch monitoring  
✅ Comprehensive README per task  
✅ Output values for downstream use  
✅ Lifecycle management  
✅ Cost-aware design  
✅ Multi-AZ resilience  

---

## General Deployment Instructions

### Prerequisites
1. AWS Free Tier account
2. Terraform >= 1.0
3. AWS CLI configured
4. Appropriate IAM permissions

### Deployment Order
```bash
# 1. Networking (Task 1)
cd 1_Networking_VPC
terraform init
terraform apply -var "prefix=Harsh_Gupta_"
# Save: VPC ID, Subnet IDs

# 2. EC2 Website (Task 2)
cd ../2_EC2_Static_Website
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_id=subnet-xxxxx"

# 3. HA & Scaling (Task 3)
cd ../3_HA_AutoScaling
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-1\",\"subnet-2\"]" \
  -var "private_subnet_ids=[\"subnet-3\",\"subnet-4\"]"

# 4. Billing (Task 4)
cd ../4_Billing_Alerts
terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "threshold_usd=1.2" \
  -var "email_address=your-email@example.com"

# 5. Architecture Diagram (Task 5)
# Create diagram on draw.io (see Task 5 README)
```

### Cleanup (reverse order)
```bash
cd 4_Billing_Alerts && terraform destroy -var "prefix=Harsh_Gupta_"
cd ../3_HA_AutoScaling && terraform destroy -var "prefix=Harsh_Gupta_" ...
cd ../2_EC2_Static_Website && terraform destroy -var "prefix=Harsh_Gupta_" ...
cd ../1_Networking_VPC && terraform destroy -var "prefix=Harsh_Gupta_"
```

---

## AWS Services Used

| Service | Purpose | Free Tier |
|---------|---------|-----------|
| VPC | Network isolation | Yes |
| EC2 | Compute | Yes (750 hrs/mo) |
| ALB | Load balancing | No (~$16/mo) |
| Auto Scaling | Dynamic scaling | Yes |
| CloudWatch | Monitoring | Yes (limited) |
| SNS | Notifications | Yes (1000 emails) |
| Budgets | Cost tracking | Yes |
| S3 | Storage | Yes (5 GB) |
| CloudFront | CDN | Yes (50 GB/mo) |
| IAM | Access control | Yes |
| Systems Manager | Instance mgmt | Yes |

---

## Important Notes

1. **Free Tier Coverage**:
   - EC2 t2.micro: 750 hours/month (12 months)
   - Other services have limits; monitor usage

2. **Billing Alerts**:
   - Regional: us-east-1 (billing metrics)
   - Compare ₹100 → ~$1.20 USD

3. **Regional Settings**:
   - Primary: ap-south-1 (Mumbai)
   - Billing: us-east-1 (required)

4. **Security**:
   - Change default passwords
   - Rotate access keys
   - Enable MFA
   - Use temporary credentials

5. **Cost Management**:
   - Delete resources after testing
   - Monitor billing dashboard daily
   - Act on alerts immediately
   - Use free tier wisely

---

## Assessment Deliverables Checklist

✅ **Task 1**: VPC, subnets, IGW, NAT, route tables, CIDR planning, Terraform, README  
✅ **Task 2**: EC2, Nginx, resume, hardening, security group, Terraform, README  
✅ **Task 3**: ALB, ASG, multi-AZ, health checks, scaling, Terraform, README  
✅ **Task 4**: CloudWatch alarms, budgets, SNS, email, cost analysis, Terraform, README  
✅ **Task 5**: Architecture diagram, 10,000 user capacity, all components, README  

---

## How to Use This Repository

### For Demonstration
1. Follow deployment instructions
2. Capture AWS console screenshots
3. Verify functionality
4. Monitor costs and alarms
5. Document findings

### For Learning
1. Study Terraform configurations
2. Understand resource dependencies
3. Learn AWS best practices
4. Analyze architecture design
5. Review security implementations

### For Production
1. Adapt for your use case
2. Add additional monitoring
3. Implement disaster recovery
4. Perform security hardening
5. Optimize for your costs

---

## Contact & Resources

- **Author**: Harsh Gupta
- **Date**: December 2025
- **AWS Region**: ap-south-1 (except billing: us-east-1)
- **Terraform**: >= 1.0
- **Account Type**: Free Tier

**Useful Links**:
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Status**: Ready for Assessment  
**Last Updated**: December 4, 2025  
**All Tasks**: Complete
