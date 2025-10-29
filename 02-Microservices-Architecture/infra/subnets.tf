/*
resource "aws_subnet" "public" {
vpc_id = aws_vpc.main.id
cidr_block = var.public_subnet_cidrs[each.value]
availability_zone = "${var.aws_region}${var.azs[each.value]}"
map_public_ip_on_launch = true
tags = { Name = "${local.name_prefix}-public-${each.value}" }
}
*/

resource "aws_subnet" "uiprivate" {
for_each = toset(range(length(var.ui_private_subnet_cidrs)))
vpc_id = aws_vpc.main.id
cidr_block = var.ui_private_subnet_cidrs[each.value]
availability_zone = "${var.aws_region}${var.azs[each.value]}"
tags = { Name = "${local.name_prefix}-private-${each.value}" }
}


resource "aws_subnet" "private" {
for_each = toset(range(length(var.private_subnet_cidrs)))
vpc_id = aws_vpc.main.id
cidr_block = var.private_subnet_cidrs[each.value]
availability_zone = "${var.aws_region}${var.azs[each.value]}"
tags = { Name = "${local.name_prefix}-private-${each.value}" }
}


resource "aws_subnet" "db" {
for_each = toset(range(length(var.db_subnet_cidrs)))
vpc_id = aws_vpc.main.id
cidr_block = var.db_subnet_cidrs[each.value]
availability_zone = "${var.aws_region}${var.azs[each.value]}"
tags = { Name = "${local.name_prefix}-db-${each.value}" }
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
nat_gateway_id = aws_nat_gateway.nat[0].id
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