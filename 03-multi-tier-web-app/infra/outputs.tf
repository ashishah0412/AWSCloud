output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_app.name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.address
}

output "app_code_s3_bucket_name" {
  description = "The name of the S3 bucket for application code"
  value       = var.app_code_s3_bucket_name
}


