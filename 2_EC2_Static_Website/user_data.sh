#!/bin/bash
set -e

# System updates and security hardening
apt-get update -y
apt-get upgrade -y

# Install security tools
apt-get install -y \
  unattended-upgrades \
  nginx \
  curl \
  wget

# Enable automatic security updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
  "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg true;
Unattended-Upgrade::MinimalSteps true;
EOF

# Configure UFW firewall (allow only necessary ports)
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Install Nginx and set up resume website
systemctl enable nginx

# Create professional resume HTML
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Harsh Gupta - Resume</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #333;
    }
    .container {
      background: white;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    }
    h1 { color: #667eea; margin: 0; }
    h2 { color: #764ba2; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
    .section { margin: 25px 0; }
    .contact-info { background: #f0f0f0; padding: 15px; border-radius: 5px; }
    .skill-badge { 
      display: inline-block; 
      background: #667eea; 
      color: white; 
      padding: 5px 10px; 
      margin: 5px; 
      border-radius: 5px;
      font-size: 0.9em;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Harsh Gupta</h1>
    <p style="color: #764ba2; font-size: 1.1em;">AWS & Cloud Solutions Architect</p>
    
    <div class="section contact-info">
      <p><strong>Email:</strong> harsh.gupta@example.com</p>
      <p><strong>Location:</strong> India</p>
      <p><strong>LinkedIn:</strong> linkedin.com/in/hgupta</p>
    </div>
    
    <div class="section">
      <h2>Professional Summary</h2>
      <p>Cloud-focused engineer with expertise in AWS infrastructure, Terraform automation, and scalable systems design. Passionate about building secure, highly available architectures on the AWS platform.</p>
    </div>
    
    <div class="section">
      <h2>Technical Skills</h2>
      <div>
        <span class="skill-badge">AWS</span>
        <span class="skill-badge">Terraform</span>
        <span class="skill-badge">CloudFormation</span>
        <span class="skill-badge">EC2</span>
        <span class="skill-badge">VPC</span>
        <span class="skill-badge">RDS</span>
        <span class="skill-badge">S3</span>
        <span class="skill-badge">ALB</span>
        <span class="skill-badge">Auto Scaling</span>
        <span class="skill-badge">Linux</span>
        <span class="skill-badge">Bash</span>
        <span class="skill-badge">Python</span>
      </div>
    </div>
    
    <div class="section">
      <h2>Experience</h2>
      <h3>Cloud Infrastructure Engineer - XYZ Company</h3>
      <p><em>2023 - Present</em></p>
      <ul>
        <li>Designed and deployed scalable VPC architectures with multi-AZ high availability</li>
        <li>Automated infrastructure provisioning using Terraform, reducing deployment time by 80%</li>
        <li>Implemented cost monitoring and optimization strategies, saving 30% on AWS costs</li>
        <li>Configured CloudWatch monitoring, alarms, and automated remediation</li>
      </ul>
    </div>
    
    <div class="section">
      <h2>Certifications</h2>
      <ul>
        <li>AWS Certified Solutions Architect Associate</li>
        <li>AWS Certified Developer Associate</li>
      </ul>
    </div>
    
    <div class="section" style="text-align: center; color: #999; font-size: 0.9em;">
      <p>This resume is hosted on a secure AWS EC2 instance using Nginx | Deployed via Terraform</p>
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
# Security Headers
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
EOF

# Start Nginx
systemctl start nginx
systemctl enable nginx

# Create system metrics monitor
cat > /var/www/html/health <<'EOF'
OK
EOF

# Install CloudWatch agent
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

echo "Web server setup completed successfully with security hardening"

