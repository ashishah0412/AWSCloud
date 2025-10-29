resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${local.name_prefix}-cloudtrail-${var.aws_region}-${var.account_id}"
  force_destroy = false
  tags = { Name = "${local.name_prefix}-cloudtrail-bucket" }
}


resource "aws_s3_bucket_public_access_block" "block" {
bucket = aws_s3_bucket.cloudtrail_bucket.id
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}