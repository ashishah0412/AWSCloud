variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-tier-web-app"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (e.g., ami-0abcdef1234567890 for Ubuntu 20.04 LTS)"
  type        = string
  default     = "ami-053b0a9d3137691b6" # Example: Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
  default     = "your-key-pair-name" # IMPORTANT: Replace with your actual key pair name
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "app_code_s3_bucket_name" {
  description = "Name of the S3 bucket to store application code for deployment"
  type        = string
  default     = "your-app-code-s3-bucket-unique-name" # IMPORTANT: Replace with a unique S3 bucket name
}


