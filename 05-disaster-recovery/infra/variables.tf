variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "dr-replication"
}

variable "primary_region" {
  description = "AWS Region for the primary deployment"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "AWS Region for the secondary (DR) deployment"
  type        = string
  default     = "us-west-2"
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "drdb"
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


