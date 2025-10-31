resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr
enable_dns_support = true
enable_dns_hostnames = true
tags = { Name = "prod-vpc" }
}


resource "aws_subnet" "private" {
count = length(var.azs)
vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index)
availability_zone = var.azs[count.index]
tags = { Name = "private-subnet-${count.index}" }
}
