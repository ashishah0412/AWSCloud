output "vpc_id" { value = aws_vpc.main.id }
output "alb_arn" { value = module.alb.alb_arn }
output "ecs_cluster" { value = aws_ecs_cluster.main.id }
output "rds_endpoint" { value = aws_db_instance.postgres.address }
output "ecr_repo" { value = aws_ecr_repository.app_repo.repository_url }