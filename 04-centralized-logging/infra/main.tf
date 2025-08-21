provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

resource "aws_security_group" "opensearch_sg" {
  name        = "${var.project_name}-opensearch-sg"
  description = "Security group for OpenSearch Service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Allow access from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-opensearch-sg"
  }
}

resource "aws_opensearch_domain" "main" {
  domain_name           = "${var.project_name}-domain"
  engine_version        = "OpenSearch_2.11"
  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  vpc_options {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:us-east-1:YOUR_AWS_ACCOUNT_ID:domain/${var.project_name}-domain/*"
    }
  ]
}
POLICY

  tags = {
    Name = "${var.project_name}-opensearch-domain"
  }
}

resource "aws_s3_bucket" "log_archive" {
  bucket = "${var.project_name}-log-archive-${random_string.bucket_suffix.id}"

  tags = {
    Name = "${var.project_name}-log-archive"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_s3_bucket_acl" "log_archive_acl" {
  bucket = aws_s3_bucket.log_archive.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "log_archive_versioning" {
  bucket = aws_s3_bucket.log_archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.project_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-firehose-role"
  }
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project_name}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = [
          aws_s3_bucket.log_archive.arn,
          "${aws_s3_bucket.log_archive.arn}/*"
        ]
      },
      {
        Action = [
          "es:DescribeDomain",
          "es:DescribeDomains",
          "es:DescribeDomainConfig",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet"
        ],
        Effect   = "Allow",
        Resource = aws_opensearch_domain.main.arn
      },
      {
        Action = [
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:log-group:/aws/kinesisfirehose/${var.project_name}-firehose-stream:*"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "${var.project_name}-firehose-stream"
  destination = "amazon_opensearch"
  s3_backup_mode = "AllDocuments"
  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.log_archive.arn
    buffer_size        = 5 # MB
    buffer_interval    = 300 # seconds
    compression_format = "UNCOMPRESSED"
  }

  amazon_opensearch_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    domain_arn      = aws_opensearch_domain.main.arn
    index_name      = "logs"
    type_name       = "_doc"
    index_rotation_period = "OneDay"
    buffer_size     = 5 # MB
    buffer_interval = 300 # seconds
    retry_duration  = 300 # seconds
  }

  tags = {
    Name = "${var.project_name}-firehose-stream"
  }
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/application/${var.project_name}-app-logs"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "app_logs_to_firehose" {
  name            = "${var.project_name}-app-logs-to-firehose"
  log_group_name  = aws_cloudwatch_log_group.app_logs.name
  destination_arn = aws_kinesis_firehose_delivery_stream.main.arn
  filter_pattern  = ""

  depends_on = [aws_kinesis_firehose_delivery_stream.main]
}

# Optional: Lambda for log processing
resource "aws_iam_role" "lambda_log_processor_role" {
  name = "${var.project_name}-lambda-log-processor-role"

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

  tags = {
    Name = "${var.project_name}-lambda-log-processor-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_log_processor_policy" {
  role       = aws_iam_role.lambda_log_processor_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_firehose_access" {
  name = "${var.project_name}-lambda-firehose-access"
  role = aws_iam_role.lambda_log_processor_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Effect   = "Allow",
        Resource = aws_kinesis_firehose_delivery_stream.main.arn
      }
    ]
  })
}

resource "aws_lambda_function" "log_processor" {
  filename         = "../app/log_processor_lambda/function.zip"
  function_name    = "${var.project_name}-log-processor"
  role             = aws_iam_role.lambda_log_processor_role.arn
  handler          = "main.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../app/log_processor_lambda/function.zip")
  timeout          = 30

  tags = {
    Name = "${var.project_name}-log-processor-lambda"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "app_logs_to_lambda" {
  name            = "${var.project_name}-app-logs-to-lambda"
  log_group_name  = aws_cloudwatch_log_group.app_logs.name
  destination_arn = aws_lambda_function.log_processor.arn
  filter_pattern  = ""

  depends_on = [aws_lambda_function.log_processor]
}

resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_processor.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.app_logs.arn
}


