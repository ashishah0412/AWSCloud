provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_backend" {
  bucket = "${var.project_name}-terraform-state-${random_string.bucket_suffix.id}"

  tags = {
    Name = "${var.project_name}-terraform-state"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_s3_bucket_versioning" "terraform_backend_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-terraform-locks"
  }
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "${var.project_name}-example-bucket-${random_string.example_bucket_suffix.id}"

  tags = {
    Name = "${var.project_name}-example-bucket"
  }
}

resource "random_string" "example_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}


