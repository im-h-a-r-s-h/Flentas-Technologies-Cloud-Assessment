Task 2 - EC2 Static Website Hosting (Resume)
============================================

Approach & Implementation
-------------------------

I deployed a production-ready, hardened static website hosting solution on AWS:

### Architecture Overview:

*   **Compute:** t2.micro EC2 instance in public subnet with auto-assigned public IP
*   **Web Server:** Nginx for lightweight, high-performance static content delivery
*   **Content:** Professional HTML resume with embedded styling and animations
*   **Security:** Multi-layered hardening including IAM roles, security groups, encrypted EBS, firewall rules, and security headers
*   **Monitoring:** CloudWatch agent for system metrics and logs collection

Security Hardening Measures Implemented
---------------------------------------

### 1\. Network Security:

*   Restrictive Security Group: Only HTTP (80), HTTPS (443), and SSH (22) allowed
*   Public IP assignment for direct internet access
*   Egress rule allows outbound connectivity for updates

### 2\. Operating System Hardening:

*   Enabled automatic security updates via `unattended-upgrades`
*   Ubuntu UFW firewall enabled with explicit allow rules
*   Disabled unnecessary services

### 3\. Instance Configuration:

*   Encrypted EBS root volume (AES-256)
*   IAM role attached for secure AWS API access
*   CloudWatch monitoring enabled for instance metrics
*   SSM Session Manager support for secure shell access

### 4\. Web Server Hardening:

*   Security headers configured (X-Content-Type-Options, X-Frame-Options, CSP)
*   Nginx runs as dedicated user (www-data)
*   Proper file permissions (755 for web root)

### 5\. Application Security:

*   Professional resume with no sensitive information exposure
*   Health check endpoint for monitoring
*   No default Nginx information disclosure

Deployment Instructions
-----------------------

**Prerequisites:** Task 1 must be completed to obtain VPC and subnet IDs

    
    cd 2_EC2_Static_Website
    terraform init
    terraform plan \
      -var "prefix=Harsh_Gupta_" \
      -var "vpc_id=vpc-xxxxx" \
      -var "public_subnet_id=subnet-xxxxx"
    terraform apply \
      -var "prefix=Harsh_Gupta_" \
      -var "vpc_id=vpc-xxxxx" \
      -var "public_subnet_id=subnet-xxxxx"
    

Screenshots to Capture
----------------------

1.  **EC2 Instance Details**  
    ![EC2 Instance Details](./ss/IMG-20251204-WA0010.jpg)
2.  **IAM Role Attached**  
    ![IAM Role](./ss/task2/IMG-2025120-WA0007.jpg)


Cleanup
-------

    
    terraform destroy \
      -var "prefix=Harsh_Gupta_" \
      -var "vpc_id=vpc-xxxxx" \
      -var "public_subnet_id=subnet-xxxxx"
    

Key Hardening Features
----------------------

*   ✔ Encrypted storage at rest
*   ✔ Automatic security updates
*   ✔ Firewall enabled with minimal rules
*   ✔ Security headers to prevent common attacks
*   ✔ IAM-based access control
*   ✔ CloudWatch monitoring integration
*   ✔ Professional resume content
