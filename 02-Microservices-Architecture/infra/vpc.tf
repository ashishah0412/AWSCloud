resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr
enable_dns_hostnames = true
enable_dns_support = true
tags = {
Name = "${local.name_prefix}-vpc"
}
}


resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main.id
tags = { Name = "${local.name_prefix}-igw" }
}


resource "aws_eip" "nat" {
count = 1
}


resource "aws_nat_gateway" "nat" {
allocation_id = aws_eip.nat[0].id
subnet_id = aws_subnet.public[0].id
tags = { Name = "${local.name_prefix}-natgw" }
}