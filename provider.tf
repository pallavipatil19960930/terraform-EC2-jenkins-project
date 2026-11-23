terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
   backend "s3" {
    bucket       = "terraform-jenkins-state-793826056374"
    key          = "terraform-jenkins-project/terraform.tfstate"
    region        = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}