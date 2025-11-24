# outputs.tf

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Output the subnet A ID
output "subnet_a_id" {
  description = "The ID of subnet A"
  value       = aws_subnet.subnet_a.id
}

# Output the subnet B ID
output "subnet_b_id" {
  description = "The ID of subnet B"
  value       = aws_subnet.subnet_b.id
}

# Output the VPC CIDR block
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Output subnet A CIDR block
output "subnet_a_cidr_block" {
  description = "The CIDR block of subnet A"
  value       = aws_subnet.subnet_a.cidr_block
}

# Output subnet B CIDR block
output "subnet_b_cidr_block" {
  description = "The CIDR block of subnet B"
  value       = aws_subnet.subnet_b.cidr_block
}
