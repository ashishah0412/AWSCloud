resource "aws_ecs_service" "backend" {
for_each = var.ecs_services
name = each.key
cluster = aws_ecs_cluster.main.id
task_definition = aws_ecs_task_definition.backend[each.key].arn
launch_type = "FARGATE"
desired_count = 2
network_configuration {
subnets = var.private_subnets
assign_public_ip = false
}
load_balancer {
target_group_arn = var.api_alb_tgs[each.key]
container_name = each.key
container_port = each.value.port
}
}