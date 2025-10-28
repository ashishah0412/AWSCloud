# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
name = "${local.name_prefix}-ecs-task-exec"
assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}


data "aws_iam_policy_document" "ecs_task_assume_role" {
statement {
actions = ["sts:AssumeRole"]
principals {
type = "Service"
identifiers = ["ecs-tasks.amazonaws.com"]
}
}
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
role = aws_iam_role.ecs_task_execution_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Minimal policy for access to secrets and logs
resource "aws_iam_policy" "ecs_task_policy" {
name = "${local.name_prefix}-ecs-task-policy"
description = "Policy for ECS tasks to read secrets and write logs"
policy = jsonencode({
Version = "2012-10-17",
Statement = [
{
Action = ["secretsmanager:GetSecretValue"],
Effect = "Allow",
Resource = "*"
},
{
Action = ["logs:CreateLogStream","logs:PutLogEvents"],
Effect = "Allow",
Resource = "*"
}
]
})
}


resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
role = aws_iam_role.ecs_task_execution_role.name
policy_arn = aws_iam_policy.ecs_task_policy.arn
}