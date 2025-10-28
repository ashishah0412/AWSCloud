resource "aws_cloudtrail" "org_trail" {
name = "${local.name_prefix}-cloudtrail"
s3_bucket_name = aws_s3_bucket.cloudtrail_bucket.id
include_global_service_events = true
is_multi_region_trail = true
enable_log_file_validation = true
kms_key_id = aws_kms_key.cmk.arn
depends_on = [aws_s3_bucket.cloudtrail_bucket]
}


resource "aws_guardduty_detector" "gd" {
enable = true
}


resource "aws_securityhub_account" "sh" {
depends_on = [aws_guardduty_detector.gd]
}