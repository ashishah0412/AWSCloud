resource "aws_db_subnet_group" "rds" {
name = "${local.name_prefix}-rds-subnet-group"
subnet_ids = [for s in aws_subnet.db : s.id]
tags = { Name = "${local.name_prefix}-rds-subnet" }
}


resource "aws_db_instance" "postgres" {
identifier = "${local.name_prefix}-pg"
engine = "postgres"
engine_version = "15"
instance_class = "db.t4g.medium"
allocated_storage = 20
storage_type = "gp3"
username = var.rds_username
password = var.rds_password
db_subnet_group_name = aws_db_subnet_group.rds.name
vpc_security_group_ids = [aws_security_group.rds_sg.id]
multi_az = true
skip_final_snapshot = false
tags = { Name = "${local.name_prefix}-rds" }
storage_encrypted = true
kms_key_id = aws_kms_key.cmk.key_id
}