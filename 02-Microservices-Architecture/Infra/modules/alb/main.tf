resource "aws_lb" "alb" {
name = "${var.name_prefix}-alb"
internal = false
load_balancer_type = "application"
subnets = var.public_subnet_ids
security_groups = [var.security_group_id]
enable_deletion_protection = false
tags = { Name = "${var.name_prefix}-alb" }
}


resource "aws_lb_target_group" "tg" {
name = "${var.name_prefix}-tg"
port = 8080
protocol = "HTTP"
vpc_id = var.vpc_id
health_check {
path = "/health"
matcher = "200-399"
interval = 30
timeout = 5
unhealthy_threshold = 2
healthy_threshold = 3
}
}


resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.alb.arn
port = "80"
protocol = "HTTP"
default_action {
type = "forward"
target_group_arn = aws_lb_target_group.tg.arn
}
}


output "alb_arn" { value = aws_lb.alb.arn }
output "target_group_arn" { value = aws_lb_target_group.tg.arn }