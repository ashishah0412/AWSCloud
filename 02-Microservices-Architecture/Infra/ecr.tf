resource "aws_ecr_repository" "app_repo" {
name = "${local.name_prefix}-app"
image_tag_mutability = "MUTABLE"
image_scanning_configuration {
scan_on_push = true
}
tags = { Name = "${local.name_prefix}-ecr" }
}