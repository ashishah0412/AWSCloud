output "vpc_id" { value = module.network.vpc_id }
output "private_subnets" { value = module.network.private_subnets }
output "ecs_cluster_id" { value = module.ecs.cluster_id }
output "ui_alb_dns" { value = module.alb.ui_alb_dns }
output "api_alb_dns" { value = module.alb.api_alb_dns }
output "rds_endpoint" { value = module.rds.db_endpoint }