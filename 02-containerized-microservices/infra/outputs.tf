output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service1_ecr_repo_url" {
  description = "The URL of the ECR repository for Service 1"
  value       = aws_ecr_repository.service1_repo.repository_url
}

output "service2_ecr_repo_url" {
  description = "The URL of the ECR repository for Service 2"
  value       = aws_ecr_repository.service2_repo.repository_url
}

output "service1_name" {
  description = "The name of ECS Service 1"
  value       = aws_ecs_service.service1.name
}

output "service2_name" {
  description = "The name of ECS Service 2"
  value       = aws_ecs_service.service2.name
}


