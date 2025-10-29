resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : tostring(idx) => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.aws_region}${var.azs[tonumber(each.key)]}"
  map_public_ip_on_launch = true
  tags = { Name = "${local.name_prefix}-public-${each.key}" }
}



resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : tostring(idx) => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.aws_region}${var.azs[tonumber(each.key)]}"
  tags = { Name = "${local.name_prefix}-private-${each.key}" }
}



resource "aws_subnet" "db" {
  for_each = { for idx, cidr in var.db_subnet_cidrs : tostring(idx) => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.aws_region}${var.azs[tonumber(each.key)]}"
  tags = { Name = "${local.name_prefix}-db-${each.key}" }
}



resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = { Name = "${local.name_prefix}-public-rt" }
}



resource "aws_route_table_association" "pub_assoc" {
for_each = aws_subnet.public
subnet_id = each.value.id
route_table_id = aws_route_table.public.id
}



resource "aws_route_table" "private" {
vpc_id = aws_vpc.main.id
tags = { Name = "${local.name_prefix}-private-rt" }
}



resource "aws_route" "private_nat" {
route_table_id = aws_route_table.private.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id
}



resource "aws_route_table_association" "private_assoc" {
for_each = aws_subnet.private
subnet_id = each.value.id
route_table_id = aws_route_table.private.id
}



resource "aws_route_table_association" "db_assoc" {
for_each = aws_subnet.db
subnet_id = each.value.id
route_table_id = aws_route_table.private.id
}