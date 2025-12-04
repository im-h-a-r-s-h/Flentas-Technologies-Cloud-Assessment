#!/bin/bash
set -e

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# System updates
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y \
  nginx \
  curl \
  wget \
  unattended-upgrades \
  jq

# Enable automatic security updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
  "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg true;
Unattended-Upgrade::MinimalSteps true;
EOF

# Configure UFW firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp

# Create dynamic resume page with instance information
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Harsh Gupta - Resume (HA Setup)</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      padding: 20px;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
      background: white;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    }
    header {
      border-bottom: 3px solid #667eea;
      padding-bottom: 20px;
      margin-bottom: 30px;
    }
    h1 { color: #667eea; font-size: 2.5em; margin-bottom: 10px; }
    .subtitle { color: #764ba2; font-size: 1.2em; }
    .instance-info {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px;
      border-radius: 5px;
      margin: 20px 0;
      font-family: monospace;
    }
    .instance-info p { margin: 8px 0; }
    .instance-info strong { color: #fff; }
    section {
      margin: 30px 0;
    }
    section h2 {
      color: #764ba2;
      border-bottom: 2px solid #667eea;
      padding-bottom: 10px;
      margin-bottom: 15px;
    }
    .skill-badge {
      display: inline-block;
      background: #667eea;
      color: white;
      padding: 8px 15px;
      margin: 5px 5px 5px 0;
      border-radius: 5px;
      font-size: 0.95em;
      font-weight: 500;
    }
    ul { margin-left: 20px; }
    li { margin: 10px 0; }
    .footer {
      text-align: center;
      color: #999;
      font-size: 0.9em;
      margin-top: 40px;
      border-top: 1px solid #eee;
      padding-top: 20px;
    }
    .status { color: #28a745; font-weight: bold; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>Harsh Gupta</h1>
      <p class="subtitle">AWS & Cloud Solutions Architect</p>
    </header>

    <div class="instance-info">
      <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
      <p><strong>Availability Zone:</strong> ${AVAILABILITY_ZONE}</p>
      <p><strong>Status:</strong> <span class="status">✓ Running (via Auto Scaling Group)</span></p>
      <p><strong>Server Time:</strong> $(date)</p>
    </div>

    <section>
      <h2>Professional Summary</h2>
      <p>Cloud infrastructure engineer with expertise in designing highly available, scalable systems on AWS. Specializing in Infrastructure as Code, multi-tier architectures, and cost-optimized solutions. This page demonstrates a highly available setup with:</p>
      <ul>
        <li>Multi-AZ deployment via Auto Scaling Group</li>
        <li>Load balancing with Application Load Balancer</li>
        <li>Auto-scaling capabilities based on demand</li>
        <li>Secure, hardened infrastructure</li>
        <li>Full monitoring and observability</li>
      </ul>
    </section>

    <section>
      <h2>Technical Expertise</h2>
      <div>
        <span class="skill-badge">AWS Architecture</span>
        <span class="skill-badge">Terraform IaC</span>
        <span class="skill-badge">VPC Design</span>
        <span class="skill-badge">EC2 Management</span>
        <span class="skill-badge">Load Balancing</span>
        <span class="skill-badge">Auto Scaling</span>
        <span class="skill-badge">CloudWatch</span>
        <span class="skill-badge">RDS/Databases</span>
        <span class="skill-badge">S3/Storage</span>
        <span class="skill-badge">Security Groups</span>
        <span class="skill-badge">IAM</span>
        <span class="skill-badge">Linux/Bash</span>
        <span class="skill-badge">Python</span>
        <span class="skill-badge">CI/CD</span>
      </div>
    </section>

    <section>
      <h2>Key Achievements</h2>
      <ul>
        <li>Designed and deployed multi-tier VPC architecture supporting 10,000+ concurrent users</li>
        <li>Implemented Auto Scaling Groups reducing manual intervention by 95%</li>
        <li>Configured CloudWatch monitoring and alerts for proactive incident response</li>
        <li>Applied infrastructure hardening reducing security vulnerabilities by 80%</li>
        <li>Optimized costs through reserved instances and spot instances saving 40% annually</li>
      </ul>
    </section>

    <section>
      <h2>AWS Services Mastery</h2>
      <ul>
        <li><strong>Compute:</strong> EC2, Auto Scaling, Lambda, ECS</li>
        <li><strong>Networking:</strong> VPC, Subnets, Route Tables, NAT Gateway, ALB, NLB</li>
        <li><strong>Storage:</strong> S3, EBS, EFS</li>
        <li><strong>Database:</strong> RDS (MySQL, PostgreSQL), DynamoDB, Aurora</li>
        <li><strong>Monitoring:</strong> CloudWatch, CloudTrail, X-Ray</li>
        <li><strong>Security:</strong> IAM, Security Groups, NACLs, KMS, Secrets Manager</li>
      </ul>
    </section>

    <div class="footer">
      <p>This resume is hosted on a highly available AWS infrastructure with Auto Scaling</p>
      <p>Deployed via Terraform | Multi-AZ Deployment | Load Balanced</p>
    </div>
  </div>
</body>
</html>
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Configure Nginx security headers
cat > /etc/nginx/conf.d/security.conf <<'EOF'
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
EOF

# Create health check endpoint
cat > /var/www/html/health <<'EOF'
{
  "status": "healthy",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "instance_id": "${INSTANCE_ID}",
  "availability_zone": "${AVAILABILITY_ZONE}"
}
EOF

# Start and enable Nginx
systemctl enable nginx
systemctl restart nginx

# Install CloudWatch agent
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb 2>/dev/null || true
dpkg -i -E ./amazon-cloudwatch-agent.deb 2>/dev/null || true
rm -f amazon-cloudwatch-agent.deb

echo "High Availability setup completed on instance ${INSTANCE_ID}"
