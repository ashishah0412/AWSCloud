output "opensearch_domain_endpoint" {
  description = "The endpoint of the OpenSearch Service domain"
  value       = aws_opensearch_domain.main.endpoint
}

output "firehose_delivery_stream_name" {
  description = "The name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.main.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for application logs"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "lambda_log_processor_name" {
  description = "The name of the Lambda log processor function (if deployed)"
  value       = try(aws_lambda_function.log_processor.function_name, "Not Deployed")
}


