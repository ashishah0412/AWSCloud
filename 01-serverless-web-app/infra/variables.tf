variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "serverless-web-app"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for static website hosting"
  type        = string
  default     = "my-serverless-webapp-bucket-unique-name"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "WebAppTable"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "WebAppLambdaFunction"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway REST API"
  type        = string
  default     = "WebAppApiGateway"
}

# variable "domain_name" {
#   description = "Custom domain name for the web application (e.g., example.com)"
#   type        = string
#   default     = "example.com"
# }

