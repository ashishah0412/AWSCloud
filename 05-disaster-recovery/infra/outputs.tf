output "primary_s3_bucket_name" {
  description = "Name of the primary S3 bucket"
  value       = aws_s3_bucket.primary_app_data.bucket
}

output "secondary_s3_bucket_name" {
  description = "Name of the secondary S3 bucket"
  value       = aws_s3_bucket.secondary_app_data.bucket
}

output "primary_rds_endpoint" {
  description = "Endpoint of the primary RDS instance"
  value       = aws_db_instance.primary.address
}

output "secondary_rds_replica_endpoint" {
  description = "Endpoint of the secondary RDS read replica"
  value       = aws_db_instance.secondary_replica.address
}

output "route53_hosted_zone_name" {
  description = "Name of the Route 53 Hosted Zone"
  value       = aws_route53_zone.main.name
}

output "application_dns_name" {
  description = "The DNS name for the application (primary/secondary failover)"
  value       = aws_route53_record.app_primary.name
}


