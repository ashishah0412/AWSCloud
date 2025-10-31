variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ui_cert_arn" {
  type = string
}

variable "api_cert_arn" {
  type = string
}

variable "ecs_services" {
  description = "Map of ECS backend services"
  type = map(object({
    port = number
  }))
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the internal ALBs"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
