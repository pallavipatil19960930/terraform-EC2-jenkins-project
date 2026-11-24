
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "ami_id" {
  description = "Fixed Ubuntu 24.04 AMI ID"
  type        = string
} 
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat or prod."
  }
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "jenkins_security_group_id" {
  description = "Jenkins EC2 security group ID"
  type        = string
}
