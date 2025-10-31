output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_reader_endpoint" {
  value = aws_db_instance.postgres.reader_endpoint
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
