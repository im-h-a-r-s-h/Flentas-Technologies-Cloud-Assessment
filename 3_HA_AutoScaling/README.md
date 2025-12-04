<h1>Task 3 - High Availability + Auto Scaling</h1>

<h2>Architecture & Design Approach</h2>

<p>I implemented a production-grade, highly available architecture designed to handle 10,000+ concurrent users.</p>

<h3>Traffic Flow Architecture:</h3>

<pre>
Internet Clients
       ↓
   [ALB in Public Subnets]
       ↓
   [Target Group]
       ↓
[EC2 Instances in Private Subnets via ASG]
       ↓
   [Nginx Web Server]
</pre>

<h3>Key Design Decisions:</h3>

<ol>
  <li><b>Load Balancer Strategy</b>
    <ul>
      <li>Internet-facing Application Load Balancer (ALB) in public subnets</li>
      <li>Handles HTTP traffic on port 80</li>
      <li>High availability across AZs</li>
    </ul>
  </li>

  <li><b>Private Subnet Architecture</b>
    <ul>
      <li>EC2 instances run in private subnets</li>
      <li>Only ALB → EC2 traffic allowed</li>
      <li>Internet access via NAT Gateway for updates</li>
    </ul>
  </li>

  <li><b>Auto Scaling Group Configuration</b>
    <ul>
      <li>Min: 2 instances</li>
      <li>Desired: 2 instances</li>
      <li>Max: 3 instances</li>
      <li>Multi-AZ deployment</li>
    </ul>
  </li>

  <li><b>Health Management</b>
    <ul>
      <li>ALB health checks (30 sec)</li>
      <li>Auto replacement of failed instances</li>
    </ul>
  </li>

  <li><b>Scaling Policies</b>
    <ul>
      <li>Scale Up: CPU > 70% for 2 minutes</li>
      <li>Scale Down: CPU < 30% for 2 minutes</li>
      <li>5-minute cooldown</li>
    </ul>
  </li>

  <li><b>Security Implementation</b>
    <ul>
      <li>ALB SG open on ports 80/443</li>
      <li>EC2 SG only allows ALB traffic</li>
      <li>Encrypted EBS, IAM roles applied</li>
    </ul>
  </li>
</ol>

<h2>Traffic Flow & Routing</h2>

<pre>
1. User connects to ALB DNS
2. ALB distributes across public subnets (ap-south-1a & 1b)
3. ALB forwards to target group on port 80
4. Private EC2 instances receive traffic
5. Nginx responds with web/resume content
6. Response returns via ALB to client
</pre>

<h2>Deployment Instructions</h2>

<p><b>Prerequisite:</b> Task 1 VPC + Subnets must exist</p>

<pre>
cd 3_HA_AutoScaling
terraform init

terraform plan \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"

terraform apply \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"
</pre>

<h2>Screenshots to Capture</h2>

<ol>
  <li><b>Application Load Balancer</b>
    <ul>
      <li>ALB name, DNS, subnets, AZs</li>
      <li>Security groups</li>
    </ul>
  </li>

  <li><b>Target Group</b>
    <ul>
      <li>Protocol, health checks</li>
      <li>Registered targets</li>
    </ul>
  </li>

  <li><b>Auto Scaling Group</b>
    <ul>
      <li>Min/Max/Desired capacity</li>
      <li>Launch template</li>
      <li>Scaling policies</li>
    </ul>
  </li>

  <li><b>EC2 Instances (ASG)</b>
    <ul>
      <li>Instance IDs, private IPs</li>
      <li>AZ mapping</li>
    </ul>
  </li>

  <li><b>Website via ALB</b>
    <ul>
      <li>Browser screenshot using ALB DNS</li>
    </ul>
  </li>

  <li><b>CloudWatch Metrics</b></li>

  <li><b>Security Groups</b></li>
</ol>

<h2>Scaling Test Procedure</h2>

<pre>
sudo apt-get install -y stress
stress --cpu 4 --timeout 5m
</pre>

<h2>Monitoring & Observability</h2>
<ul>
  <li>CloudWatch alarms (CPU high/low)</li>
  <li>ALB target group health</li>
  <li>EC2 + ASG metrics</li>
</ul>

<h2>Cost Optimization</h2>
<ul>
  <li>Minimum 2 instances</li>
  <li>Free tier t2.micro</li>
  <li>ASG prevents over-provisioning</li>
</ul>

<h2>Cleanup</h2>

<pre>
terraform destroy \
  -var "prefix=Harsh_Gupta_" \
  -var "vpc_id=vpc-xxxxx" \
  -var "public_subnet_ids=[\"subnet-public1\", \"subnet-public2\"]" \
  -var "private_subnet_ids=[\"subnet-private1\", \"subnet-private2\"]"
</pre>

<h2>Key HA Features</h2>

<ul>
  <li>Multi-AZ deployment</li>
  <li>Automatic instance replacement</li>
  <li>Dynamic scaling</li>
  <li>Health-based ALB routing</li>
  <li>Encrypted data at rest</li>
  <li>Monitoring via CloudWatch</li>
  <li>SG-based access control</li>
  <li>User-data automated updates</li>
  <li>Instance metadata included</li>
</ul>
