resource "aws_ecs_cluster" "main" {
name = "${local.name_prefix}-ecs-cluster"
}


# Task definition (simplified)
resource "aws_ecs_task_definition" "app" {
family = "${local.name_prefix}-task"
network_mode = "awsvpc"
requires_compatibilities = ["FARGATE"]
cpu = "512"
memory = "1024"
execution_role_arn = aws_iam_role.ecs_task_execution_role.arn


container_definitions = jsonencode([
{
name = "app"
image = "${aws_ecr_repository.app_repo.repository_url}:latest"
essential = true
portMappings = [{containerPort=8080,protocol="tcp"}]
environment = [ { name = "ENV", value = var.environment } ]
logConfiguration = {
logDriver = "awslogs",
options = {
"awslogs-group" = "/ecs/${local.name_prefix}",
"awslogs-region" = var.aws_region,
"awslogs-stream-prefix" = "app"
}
}
}
])
}