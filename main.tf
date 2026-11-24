
# Get latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create Security Group
resource "aws_security_group" "web_sg" {
  name        = "terraform-jenkins-web-sg-${var.environment}"
  description = "Allow HTTP and Jenkins SSH access"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SSH from Jenkins"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.jenkins_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-jenkins-web-sg-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "Terraform-Jenkins-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
