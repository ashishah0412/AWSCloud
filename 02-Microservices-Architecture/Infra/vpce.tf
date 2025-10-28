# VPC Endpoint for S3 (Gateway)
resource "aws_vpc_endpoint" "s3" {
vpc_id = aws_vpc.main.id
service_name = "com.amazonaws.${var.aws_region}.s3"
route_table_ids = [aws_route_table.public.id, aws_route_table.private.id]
}


# Interface endpoints for secretsmanager, ecr api, ecr dkr, logs
resource "aws_vpc_endpoint" "secretsmanager" {
vpc_id = aws_vpc.main.id
vpc_endpoint_type = "Interface"
service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
subnet_ids = [for s in aws_subnet.private : s.id]
security_group_ids = [aws_security_group.ecs_sg.id]
}


resource "aws_vpc_endpoint" "ecr_api" {
vpc_id = aws_vpc.main.id
vpc_endpoint_type = "Interface"
service_name = "com.amazonaws.${var.aws_region}.ecr.api"
subnet_ids = [for s in aws_subnet.private : s.id]
security_group_ids = [aws_security_group.ecs_sg.id]
}


resource "aws_vpc_endpoint" "ecr_dkr" {
vpc_id = aws_vpc.main.id
vpc_endpoint_type = "Interface"
service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
subnet_ids = [for s in aws_subnet.private : s.id]
security_group_ids = [aws_security_group.ecs_sg.id]
}


resource "aws_vpc_endpoint" "logs" {
vpc_id = aws_vpc.main.id
vpc_endpoint_type = "Interface"
service_name = "com.amazonaws.${var.aws_region}.logs"
subnet_ids = [for s in aws_subnet.private : s.id]
security_group_ids = [aws_security_group.ecs_sg.id]
}