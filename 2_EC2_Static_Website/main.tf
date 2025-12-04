
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "prefix" {
  type    = string
  default = "Harsh_Gupta_"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "public_subnet_id" {
  type    = string
  default = ""
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  user_data     = file("${path.module}/user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  monitoring    = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }
  tags = { Name = "${var.prefix}ec2-web" }
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_security_group" "web_sg" {
  name        = "${var.prefix}web-sg"
  vpc_id      = var.vpc_id
  description = "Security group for web server with HTTP/HTTPS and SSH"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH for management (restrict in production)"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = { Name = "${var.prefix}web-sg" }
}

# IAM Role for EC2 (allows CloudWatch logging and systems manager)
resource "aws_iam_role" "ec2_role" {
  name = "${var.prefix}ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}ec2-profile"
  role = aws_iam_role.ec2_role.name
}

output "public_ip" {
  value = aws_instance.web.public_ip
  description = "Public IP of the web server"
}

output "instance_id" {
  value = aws_instance.web.id
  description = "EC2 Instance ID"
}
