# Define AWS provider
provider "aws" {
  region = "us-east-1"  # You can change the region if needed
}

# Backend configuration
terraform {
  backend "s3" {
    bucket         = "ashi0412-tfstate-bucket"  # Replace with your bucket name
    key            = "terraform.tfstate"  # Path for storing the Terraform state in S3
    region         = "us-east-1"  # S3 bucket region
    encrypt        = true  # Encrypt the state file
    dynamodb_table = "terraform-lock-table"  # Table for state locking
    acl            = "bucket-owner-full-control"  # Optional: Set ACL for state file
  }
}

# Create a VPC resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create subnets
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-b"
  }
}
