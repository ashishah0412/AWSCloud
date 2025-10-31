resource "aws_ecs_task_definition" "ui" {
family = "ui-task"
network_mode = "awsvpc"
requires_compatibilities = ["FARGATE"]
cpu = 256
memory = 512
execution_role_arn = var.ecs_task_exec_role
task_role_arn = var.ecs_task_role


container_definitions = jsonencode([
{
name = "ui"
image = var.ui_image
portMappings = [{ containerPort = 80 }]
logConfiguration = {
logDriver = "awslogs",
options = {
awslogs-group = "/ecs/ui",
awslogs-region = "us-east-1",
awslogs-stream-prefix = "ecs"
}
}
}
])
}


resource "aws_ecs_task_definition" "backend" {
for_each = var.ecs_services
family = each.key
network_mode = "awsvpc"
requires_compatibilities = ["FARGATE"]
cpu = 256
memory = 512
execution_role_arn = var.ecs_task_exec_role
task_role_arn = var.ecs_task_role


container_definitions = jsonencode([
{
name = each.key,
image = "${var.ecr_repo_prefix}/${each.key}:latest",
portMappings = [{ containerPort = each.value.port }],
logConfiguration = {
logDriver = "awslogs",
options = {
awslogs-group = "/ecs/${each.key}",
awslogs-region = "us-east-1",
awslogs-stream-prefix = "ecs"
}
}
}
])
}