######################################
# Internal ALBs for UI and API
######################################

# UI ALB
resource "aws_lb" "ui_alb" {
  name               = "ui-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ui_alb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = true
  idle_timeout               = 60

  tags = {
    Name = "ui-internal-alb"
  }
}

# API ALB
resource "aws_lb" "api_alb" {
  name               = "api-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api_alb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = true
  idle_timeout               = 60

  tags = {
    Name = "api-internal-alb"
  }
}

######################################
# Security Groups
######################################

resource "aws_security_group" "ui_alb_sg" {
  name        = "ui-alb-sg"
  description = "Security group for UI ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ui-alb-sg"
  }
}

resource "aws_security_group" "api_alb_sg" {
  name        = "api-alb-sg"
  description = "Security group for API ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "api-alb-sg"
  }
}

######################################
# Target Groups
######################################

# UI Target Group
resource "aws_lb_target_group" "ui_tg" {
  name        = "ui-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "ui-tg"
  }
}

# API Target Groups (one per ECS service)
resource "aws_lb_target_group" "api_tgs" {
  for_each    = var.ecs_services
  name        = "${each.key}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "${each.key}-tg"
  }
}

######################################
# Listeners
######################################

# UI Listener
resource "aws_lb_listener" "ui_https" {
  load_balancer_arn = aws_lb.ui_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ui_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui_tg.arn
  }
}

# API Listener
resource "aws_lb_listener" "api_https" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.api_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = element(values(aws_lb_target_group.api_tgs), 0).arn
  }
}
