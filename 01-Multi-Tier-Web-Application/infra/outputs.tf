# AWS Cloud/projects/01-MultiTierWebApp/infra/outputs.tf
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.web_app_alb.dns_name
}

output "s3_static_website_endpoint" {
  description = "The S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.static_website_config.website_endpoint
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = aws_db_instance.web_app_db.address
  sensitive   = true
}