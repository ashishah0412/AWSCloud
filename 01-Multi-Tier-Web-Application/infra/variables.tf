# AWS Cloud/projects/01-MultiTierWebApp/infra/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-tier-app"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type for web/app servers"
  type        = string
  default     = "t3.micro"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "Optional: Name of an existing EC2 Key Pair for SSH access"
  type        = string
  default     = null
}