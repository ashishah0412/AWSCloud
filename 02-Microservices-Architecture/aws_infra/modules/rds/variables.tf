variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "db_identifier" {
  type    = string
  default = "prod-postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15.3"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = true
}
