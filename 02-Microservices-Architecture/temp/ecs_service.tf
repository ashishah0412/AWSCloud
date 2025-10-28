# ALB (simple module usage)
module "alb" {
source = "./modules/alb"
name_prefix = local.name_prefix
vpc_id = aws_vpc.main.id
public_subnet_ids = [for s in aws_subnet.public : s.id]
security_group_id = aws_security_group.alb_sg.id
}


resource "aws_ecs_service" "app" {
name = "${local.name_prefix}-svc"
cluster = aws_ecs_cluster.main.id
task_definition = aws_ecs_task_definition.app.arn
desired_count = 2
launch_type = "FARGATE"
network_configuration {
subnets = [for s in aws_subnet.private : s.id]
security_groups = [aws_security_group.ecs_sg.id]
assign_public_ip = false
}
load_balancer {
target_group_arn = module.alb.target_group_arn
container_name = "app"
container_port = 8080
}
depends_on = [module.alb]
}