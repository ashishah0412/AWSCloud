output "website_url" {
  description = "The URL of the S3 static website"
  value       = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}

output "api_gateway_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.api_lambda.function_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.webapp_table.name
}

