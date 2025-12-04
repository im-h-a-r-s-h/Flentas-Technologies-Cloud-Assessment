
AWS Technical Assessment - Harsh Gupta
======================================

Overview
--------

This repository contains a complete AWS infrastructure implementation demonstrating enterprise-grade cloud architecture design, security best practices, and infrastructure-as-code (IaC) principles. The assessment covers five key AWS domains: networking, compute, high availability, cost monitoring, and scalable architecture design.

### Repository Structure

*   `1_Networking_VPC/` - VPC design with subnets, gateways, and NAT
*   `2_EC2_Static_Website/` - Hardened EC2 instance with Nginx
*   `3_HA_AutoScaling/` - High availability setup with ALB and ASG
*   `4_Billing_Alerts/` - Cost monitoring with CloudWatch and Budgets
*   `5_Architecture_Diagram/` - Scalable architecture design for 10,000 users

* * *

Task 1: Networking & Subnetting (AWS VPC Setup)
-----------------------------------------------

### Approach

Designed a multi-tier VPC architecture with public and private subnets across two availability zones for high availability and security isolation. The VPC follows AWS best practices with appropriate CIDR planning for future expansion.

### CIDR Planning

VPC CIDR: 10.0.0.0/16 (65,536 IPs)
├── Public Subnet 1: 10.0.0.0/24 in ap-south-1a (256 IPs)
├── Public Subnet 2: 10.0.1.0/24 in ap-south-1b (256 IPs)
├── Private Subnet 1: 10.0.10.0/24 in ap-south-1a (256 IPs)
└── Private Subnet 2: 10.0.11.0/24 in ap-south-1b (256 IPs)

### Why These Ranges?

*   10.0.0.0/16: Standard RFC1918 private range, scalable for multi-tier deployments
*   Public Subnets: First octet range for intuitive identification
*   Private Subnets: Separated for better isolation
*   /24 Subnet Mask: 254 usable IPs per subnet

### Key Components

*   Internet Gateway (IGW)
*   NAT Gateway
*   Route Tables
*   Security Group Isolation

### Deployment

cd 1\_Networking\_VPC
terraform init
terraform plan -var "prefix=Harsh\_Gupta\_"
terraform apply -var "prefix=Harsh\_Gupta\_"

* * *

Task 2: EC2 Static Website Hosting (Resume)
-------------------------------------------

### Approach

Deployed a hardened EC2 instance hosting a professional resume website using Nginx, with strong security enhancements and encrypted EBS.

### Architecture

Public Internet → Security Group → EC2 (Nginx, Resume Website)

### Security Hardening Measures

*   Restricted Security Groups
*   Automatic OS Updates
*   Encrypted EBS
*   Least Privilege IAM Roles
*   Security Headers

### Deployment

cd 2\_EC2\_Static\_Website
terraform init
terraform apply \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "vpc\_id=vpc-xxxxx" \\
  -var "public\_subnet\_id=subnet-xxxxx"

* * *

Task 3: High Availability + Auto Scaling
----------------------------------------

### Approach

Implemented multi-AZ load balancer + auto-scaling for a fault-tolerant setup supporting 10,000+ users.

### Architecture Overview

Internet → ALB → Target Group → Auto Scaling Group → EC2 (Private Subnets)

### Deployment

cd 3\_HA\_AutoScaling
terraform init
terraform apply \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "vpc\_id=vpc-xxxxx" \\
  -var "public\_subnet\_ids=\[\\"subnet-1\\",\\"subnet-2\\"\]" \\
  -var "private\_subnet\_ids=\[\\"subnet-3\\",\\"subnet-4\\"\]"

* * *

Task 4: Billing & Free Tier Cost Monitoring
-------------------------------------------

### Approach

Implemented CloudWatch billing alarms, SNS notifications, and AWS Budgets for proactive cost monitoring.

### Common Cost Culprits

Resource

Monthly Cost

m5.2xlarge EC2

$900

NAT Gateway (100GB)

$100

Unattached Elastic IP

$36

### Deployment

cd 4\_Billing\_Alerts
terraform init
terraform apply \\
  -var "prefix=Harsh\_Gupta\_" \\
  -var "threshold\_usd=1.2" \\
  -var "email\_address=your-email@example.com"

* * *

Task 5: Architecture Diagram (10,000 Concurrent Users)
------------------------------------------------------

### Architecture Overview

User → Route 53 → CloudFront → ALB → ASG → Aurora + Redis → S3

### Core Components

*   CloudFront CDN
*   WAF + Shield
*   Auto Scaling
*   Aurora PostgreSQL Multi-AZ
*   Redis Caching
*   S3 Bucket Storage

* * *

Terraform Best Practices Implemented
------------------------------------

*   Modular Folder Structure
*   Tagging Standards
*   IAM Least Privilege
*   Encrypted Storage
*   Monitoring & Logging

* * *

General Deployment Instructions
-------------------------------

### Prerequisites

*   Terraform ≥ 1.0
*   AWS CLI
*   Free Tier Account
