
# Task 3 - High Availability + Auto Scaling

## Architecture & Design Approach

I implemented a production-grade, highly available architecture designed to handle 10,000+ concurrent users:

**Traffic Flow Architecture:**
```
Internet Clients
       ↓
   [ALB in Public Subnets]
       ↓
   [Target Group]
       ↓
[EC2 Instances in Private Subnets via ASG]
       ↓
   [Nginx Web Server]
```

**Key Design Decisions:**

1. **Load Balancer Strategy**
   - Internet-facing Application Load Balancer (ALB) in public subnets
   - ALB handles all incoming HTTP traffic on port 80
   - Provides a single entry point with high availability across AZs

2. **Private Subnet Architecture**
   - EC2 instances run in private subnets (no direct internet access)
   - Enhanced security: instances only receive traffic from ALB via security groups
   - Outbound internet access via NAT Gateway for updates

3. **Auto Scaling Group Configuration**
   - Min: 2 instances (high availability baseline)
   - Desired: 2 instances (normal operation)
   - Max: 3 instances (scaling ceiling)
   - Spans both AZs for fault tolerance

4. **Health Management**
   - ELB health checks every 30 seconds
   - 2 consecutive successful checks to mark healthy
   - 2 consecutive failed checks to mark unhealthy
   - Automatic instance replacement on failure

5. **Scaling Policies**
   - Scale Up: Triggered when CPU > 70% for 2 minutes
   - Scale Down: Triggered when CPU < 30% for 2 minutes
   - 5-minute cooldown to prevent flapping

6. **Security Implementation**
   - ALB Security Group: Open to internet (ports 80, 443)
   - EC2 Security Group: Restricted to ALB only (port 80)
   - Cross-group security validation
   - Encrypted EBS volumes
   - IAM roles for AWS service access

## Traffic Flow & Routing

```
1. User connects to ALB DNS name
2. ALB distributes across public subnets (ap-south-1a, ap-south-1b)
3. ALB forwards to target group on port 80
4. Traffic routed to EC2 instances in private subnets
5. Nginx responds with resume/web content
6. Response travels back through ALB to client
```

## Deployment Instructions

**Prerequisites**: Task 1 completed

```bash
cd 3_HA_AutoScaling
terraform init
terraform plan \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"
```

## Screenshots to Capture

1. **Application Load Balancer Details**
   - ALB Name, DNS name, public IP addresses
   - Availability zones and subnets
   - Security group configuration

2. **Target Group Configuration**
   - Target group name and protocol
   - Health check settings (path, interval, timeout)
   - Registered targets with health status
   - Stickiness configuration

3. **Auto Scaling Group Details**
   - ASG name, min/max/desired capacity
   - VPC and subnet configuration
   - Launch template reference
   - Scaling policies and metrics

4. **EC2 Instances from ASG**
   - List of instances with IDs
   - Private IP addresses and AZ assignments
   - Security groups attached
   - Instance state (running/pending)

5. **Website Access via ALB**
   - Browser screenshot: http://[ALB-DNS-Name]/
   - Resume page showing instance metadata
   - Instance ID and availability zone displayed

6. **CloudWatch Metrics**
   - ALB request count
   - Target response time
   - EC2 CPU utilization
   - ASG desired/running/terminating instances
   - Scaling alarms

7. **Security Group Relationships**
   - ALB security group rules
   - EC2 security group rules
   - Cross-group reference validation

## Scaling Test Procedure

To demonstrate auto-scaling:

```bash
# SSH to private instance via ALB's public subnet bastion or SSM Session Manager
# Run stress test on instance:
sudo apt-get install -y stress
stress --cpu 4 --timeout 5m

# Monitor CloudWatch to see:
# - CPU utilization increasing
# - Scale-up alarm triggering
# - New instances launching
# - Load distribution across instances
```

## Monitoring & Observability

**CloudWatch Alarms:**
- High CPU (>70%) - Triggers scale-up
- Low CPU (<30%) - Triggers scale-down
- Unhealthy hosts - ALB removes from rotation
- ALB target group health - Monitors instance health

**Metrics to Monitor:**
- Request count per instance
- Response time percentiles (p50, p90, p99)
- CPU and memory utilization
- Network in/out bytes
- ASG group metrics

## Cost Optimization

- **Min 2 instances** ensures availability without excess cost
- **t2.micro free tier** for 12 months (with Free Tier)
- **Auto Scaling** prevents over-provisioning
- **ALB** costs ~$16/month + data processing fees

## Cleanup

```bash
terraform destroy \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"
```

## Key HA Features

✅ Multi-AZ deployment across 2 AZs  
✅ Automatic instance failure recovery  
✅ Dynamic scaling based on demand  
✅ Health-based load balancing  
✅ Encrypted data at rest  
✅ CloudWatch monitoring and alarms  
✅ Security group-based access control  
✅ Automatic updates via user_data  
✅ Instance metadata exposed for debugging  
✅ Graceful shutdown with connection draining
