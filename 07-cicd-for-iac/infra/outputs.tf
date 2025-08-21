output "terraform_backend_bucket_name" {
  description = "Name of the S3 bucket used for Terraform backend"
  value       = aws_s3_bucket.terraform_backend.bucket
}

output "terraform_locks_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "example_s3_bucket_name" {
  description = "Name of the example S3 bucket created by this project"
  value       = aws_s3_bucket.example_bucket.bucket
}


