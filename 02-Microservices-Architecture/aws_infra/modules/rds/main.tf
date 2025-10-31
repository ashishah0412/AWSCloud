########## RDS - subnet group, security group, parameter group (optional), and instance ##########

# DB subnet group
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.private_subnets
  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

# Security group for RDS - allow only from ECS tasks security group (caller must adjust SG IDs accordingly)
resource "aws_security_group" "rds_sg" {
  name        = "${var.db_identifier}-sg"
  description = "RDS SG - allow access from ECS tasks"
  vpc_id      = var.vpc_id

  # By default no ingress; expect to add ingress rule from ECS tasks SG in caller or manually
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_identifier}-sg"
  }
}

# Optional DB parameter group (simple example, override as needed)
resource "aws_db_parameter_group" "this" {
  name        = "${var.db_identifier}-pg"
  family      = "postgres15"
  description = "Custom parameter group for ${var.db_identifier}"

  lifecycle {
    create_before_destroy = true
  }

  # Add parameters here if required, e.g. work_mem etc.
  parameter {
    name  = "log_min_duration_statement"
    value = "-1"
  }
  tags = {
    Name = "${var.db_identifier}-pg"
  }
}

# RDS instance (Multi-AZ)
resource "aws_db_instance" "postgres" {
  identifier              = var.db_identifier
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  parameter_group_name    = aws_db_parameter_group.this.name
  multi_az                = true
  publicly_accessible     = false
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.db_backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  tags = {
    Name = var.db_identifier
  }
}

# Output the endpoint and reader endpoint
output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_reader_endpoint" {
  value = aws_db_instance.postgres.reader_endpoint
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
