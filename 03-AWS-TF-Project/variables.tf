# variables.tf

# Define the AWS region (optional, you can also set this in provider)
variable "aws_region" {
  description = "The AWS region to deploy the VPC"
  type        = string
  default     = "us-east-1"
}

# VPC CIDR block
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet A CIDR block
variable "subnet_a_cidr" {
  description = "CIDR block for subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

# Subnet B CIDR block
variable "subnet_b_cidr" {
  description = "CIDR block for subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

# Availability zone for Subnet A
variable "subnet_a_az" {
  description = "Availability Zone for subnet A"
  type        = string
  default     = "us-east-1a"
}

# Availability zone for Subnet B
variable "subnet_b_az" {
  description = "Availability Zone for subnet B"
  type        = string
  default     = "us-east-1b"
}

# Tags for resources
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    "Environment" = "production"
    "Project"     = "vpc-project"
  }
}
