resource "aws_kms_key" "cmk" {
description = "CMK for ${local.name_prefix} encryption"
policy = data.aws_iam_policy_document.kms_policy.json
tags = { Name = "${local.name_prefix}-cmk" }
}


data "aws_iam_policy_document" "kms_policy" {
statement {
sid = "Allow administration of the key"
effect = "Allow"
principals {
type = "AWS"
identifiers = ["arn:aws:iam::${var.account_id}:root"]
}
actions = ["kms:*"]
resources = ["*"]
}
}