terraform {
  backend "s3" {
    bucket         = "YOUR_TERRAFORM_STATE_BUCKET_NAME" # Replace with your S3 bucket name
    key            = "${var.project_name}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "YOUR_TERRAFORM_LOCK_TABLE_NAME" # Replace with your DynamoDB table name
    encrypt        = true
  }
}


