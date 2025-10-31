output "ui_alb_dns" {
  value = aws_lb.ui_alb.dns_name
}

output "api_alb_dns" {
  value = aws_lb.api_alb.dns_name
}

output "ui_tg_arn" {
  value = aws_lb_target_group.ui_tg.arn
}

output "api_tg_arns" {
  value = { for k, v in aws_lb_target_group.api_tgs : k => v.arn }
}
