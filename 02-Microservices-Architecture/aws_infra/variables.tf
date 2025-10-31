variable "aws_region" { default = "us-east-1" }
variable "vpc_cidr" {}
variable "azs" { type = list(string) }

variable "ui_cert_arn" {}
variable "api_cert_arn" {}

variable "ecs_cluster_name" {}
variable "ui_image" {}
variable "ecr_repo_prefix" {}

variable "ecs_services" {
  type = map(object({
    image = string
    port  = number
  }))
}

# RDS variables
variable "db_identifier" { default = "prod-postgres" }
variable "db_engine_version" { default = "15.3" }
variable "db_instance_class" { default = "db.t3.medium" }
variable "db_allocated_storage" { default = 20 }
variable "db_username" {}
variable "db_password" { sensitive = true }
variable "rds_skip_final_snapshot" { default = true }
variable "rds_deletion_protection" { default = true }
variable "db_backup_retention_days" { default = 7 }