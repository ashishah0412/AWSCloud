variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "cluster_name" {}
variable "ui_image" {}
variable "ecs_services" { type = map(object({ image = string, port = number })) }
variable "ecr_repo_prefix" {}
variable "ui_alb_tg_arn" {}
variable "api_alb_tgs" { type = map(string) }
variable "ecs_task_exec_role" {}
variable "ecs_task_role" {}