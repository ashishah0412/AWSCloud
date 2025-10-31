terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source     = "./modules/ecr"
  repo_names = ["ui-app", "service1", "service2", "service3", "service4", "service5"]
}


module "alb" {
  source       = "./modules/alb"
  vpc_id       = module.network.vpc_id
  subnets      = module.network.private_subnets
  ui_cert_arn  = var.ui_cert_arn
  api_cert_arn = var.api_cert_arn
  ecs_services = var.ecs_services
}

module "ecs" {
  source              = "./modules/ecs"
  vpc_id              = module.network.vpc_id
  private_subnets     = module.network.private_subnets
  cluster_name        = var.ecs_cluster_name
  ui_image            = var.ui_image
  ecs_services        = var.ecs_services
  ecr_repo_prefix     = var.ecr_repo_prefix
  ui_alb_tg_arn       = module.alb.ui_tg_arn
  api_alb_tgs         = module.alb.api_tg_arns
  ecs_task_exec_role  = module.iam.ecs_task_exec_role_arn
  ecs_task_role       = module.iam.ecs_task_role_arn
}

module "rds" {
  source = "./modules/rds"

  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets

  db_identifier        = var.db_identifier
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_username          = var.db_username
  db_password          = var.db_password

  skip_final_snapshot  = var.rds_skip_final_snapshot
  deletion_protection  = var.rds_deletion_protection
  db_backup_retention_days = var.db_backup_retention_days
}
