variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "secure-network"
}

variable "on_premise_public_ip" {
  description = "Public IP address of your on-premise customer gateway device"
  type        = string
  # IMPORTANT: Replace with your actual on-premise public IP
  default     = "203.0.113.1"
}

variable "on_premise_network_cidr" {
  description = "CIDR block of your on-premise network"
  type        = string
  # IMPORTANT: Replace with your actual on-premise network CIDR
  default     = "172.16.0.0/24"
}


