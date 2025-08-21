provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Project = "ServerlessWebApp"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_dynamodb_table" "webapp_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "ServerlessWebApp"
    Environment = "Development"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.project_name}-dynamodb-access-policy"
  description = "IAM policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.webapp_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_lambda_function" "api_lambda" {
  function_name    = var.lambda_function_name
  handler          = "main.handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = "../app/lambda_function/function.zip"
  source_code_hash = filebase64sha256("../app/lambda_function/function.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.webapp_table.name
    }
  }

  tags = {
    Project = "ServerlessWebApp"
    Environment = "Development"
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_gateway_name
  description = "API Gateway for Serverless Web App"

  tags = {
    Project = "ServerlessWebApp"
    Environment = "Development"
  }
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_method.proxy_method.resource_id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_method.root_method.resource_id
  http_method             = aws_api_gateway_method.root_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  # This is to ensure that the deployment is re-created when the API Gateway methods change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.proxy_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.root_method.id,
      aws_api_gateway_integration.root_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "dev"

  tags = {
    Project = "ServerlessWebApp"
    Environment = "Development"
  }
}

# Optional: Route 53 setup for custom domain
# This requires a registered domain and a hosted zone in Route 53
# resource "aws_route53_zone" "main" {
#   name = var.domain_name
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.main.zone_id
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }

# resource "aws_api_gateway_domain_name" "custom_domain" {
#   domain_name     = var.domain_name
#   certificate_arn = aws_acm_certificate.cert.arn
#
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_base_path_mapping" "api_mapping" {
#   api_id      = aws_api_gateway_rest_api.api_gateway.id
#   domain_name = aws_api_gateway_domain_name.custom_domain.id
#   stage_name  = aws_api_gateway_stage.api_stage.stage_name
# }

# resource "aws_route53_record" "api_gateway_record" {
#   name    = var.domain_name
#   type    = "A"
#   zone_id = aws_route53_zone.main.zone_id

#   alias {
#     name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "s3_website_record" {
#   name    = "www.${var.domain_name}"
#   type    = "A"
#   zone_id = aws_route53_zone.main.zone_id

#   alias {
#     name                   = aws_s3_bucket_website_configuration.website_configuration.website_domain
#     zone_id                = aws_s3_bucket.website_bucket.hosted_zone_id
#     evaluate_target_health = false
#   }
# }


