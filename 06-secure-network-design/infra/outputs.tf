output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "prod_vpc_id" {
  description = "The ID of the Production VPC"
  value       = aws_vpc.prod.id
}

output "dev_vpc_id" {
  description = "The ID of the Development VPC"
  value       = aws_vpc.dev.id
}

output "shared_services_vpc_id" {
  description = "The ID of the Shared Services VPC"
  value       = aws_vpc.shared_services.id
}

output "vpn_connection_id" {
  description = "The ID of the Site-to-Site VPN connection"
  value       = aws_vpn_connection.on_premise_vpn.id
}


