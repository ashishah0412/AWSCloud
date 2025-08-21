provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "prod" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "${var.project_name}-prod-vpc"
  }
}

resource "aws_vpc" "dev" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "${var.project_name}-dev-vpc"
  }
}

resource "aws_vpc" "shared_services" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = "${var.project_name}-shared-services-vpc"
  }
}

resource "aws_subnet" "prod_private" {
  count             = 2
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.10.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-prod-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "dev_private" {
  count             = 2
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "10.20.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-dev-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "shared_services_private" {
  count             = 2
  vpc_id            = aws_vpc.shared_services.id
  cidr_block        = "10.30.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-shared-services-private-subnet-${count.index}"
  }
}

resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway"

  tags = {
    Name = "${var.project_name}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod" {
  vpc_id              = aws_vpc.prod.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  subnet_ids          = aws_subnet.prod_private[*].id
  dns_support         = "enable"
  ipv6_support        = "disable"
  appliance_mode_support = "disable"

  tags = {
    Name = "${var.project_name}-tgw-attach-prod"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev" {
  vpc_id              = aws_vpc.dev.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  subnet_ids          = aws_subnet.dev_private[*].id
  dns_support         = "enable"
  ipv6_support        = "disable"
  appliance_mode_support = "disable"

  tags = {
    Name = "${var.project_name}-tgw-attach-dev"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_services" {
  vpc_id              = aws_vpc.shared_services.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  subnet_ids          = aws_subnet.shared_services_private[*].id
  dns_support         = "enable"
  ipv6_support        = "disable"
  appliance_mode_support = "disable"

  tags = {
    Name = "${var.project_name}-tgw-attach-shared-services"
  }
}

resource "aws_ec2_transit_gateway_route_table" "prod" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.project_name}-tgw-rt-prod"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "prod" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_to_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_to_shared_services" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route_table" "dev" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.project_name}-tgw-rt-dev"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev_to_prod" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev_to_shared_services" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

resource "aws_ec2_transit_gateway_route_table" "shared_services" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.project_name}-tgw-rt-shared-services"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "shared_services" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_services_to_prod" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_services_to_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services.id
}

# Route tables for VPCs to point to TGW
resource "aws_route_table" "prod_to_tgw" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-prod-to-tgw-rt"
  }
}

resource "aws_route_table_association" "prod_private_to_tgw" {
  count          = 2
  subnet_id      = aws_subnet.prod_private[count.index].id
  route_table_id = aws_route_table.prod_to_tgw.id
}

resource "aws_route_table" "dev_to_tgw" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-dev-to-tgw-rt"
  }
}

resource "aws_route_table_association" "dev_private_to_tgw" {
  count          = 2
  subnet_id      = aws_subnet.dev_private[count.index].id
  route_table_id = aws_route_table.dev_to_tgw.id
}

resource "aws_route_table" "shared_services_to_tgw" {
  vpc_id = aws_vpc.shared_services.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-shared-services-to-tgw-rt"
  }
}

resource "aws_route_table_association" "shared_services_private_to_tgw" {
  count          = 2
  subnet_id      = aws_subnet.shared_services_private[count.index].id
  route_table_id = aws_route_table.shared_services_to_tgw.id
}

# Site-to-Site VPN
resource "aws_customer_gateway" "on_premise" {
  bgp_asn    = 65000
  ip_address = var.on_premise_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-on-premise-cgw"
  }
}

resource "aws_vpn_connection" "on_premise_vpn" {
  vpn_gateway_id      = aws_ec2_transit_gateway.main.id # Attach to TGW
  customer_gateway_id = aws_customer_gateway.on_premise.id
  type                = "ipsec.1"
  static_routes_only  = true

  static_routes = [
    var.on_premise_network_cidr
  ]

  tags = {
    Name = "${var.project_name}-on-premise-vpn"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


