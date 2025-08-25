# AWS Cloud/projects/01-MultiTierWebApp/infra/backend.tf
terraform {
  backend "s3" {
    bucket         = "ashi0412-tfstate-bucket"
    key            = "multi-tier-web-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
