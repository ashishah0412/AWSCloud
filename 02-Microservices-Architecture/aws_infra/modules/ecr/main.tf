resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repo_names)
  name     = each.value
}

output "repo_urls" {
  value = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}
