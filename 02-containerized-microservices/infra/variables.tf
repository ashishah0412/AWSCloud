variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ecs-microservices"
}

variable "service_cpu" {
  description = "CPU units for ECS Fargate tasks"
  type        = number
  default     = 256 # 0.25 vCPU
}

variable "service_memory" {
  description = "Memory (in MiB) for ECS Fargate tasks"
  type        = number
  default     = 512 # 0.5 GB
}

variable "service_desired_count" {
  description = "Desired number of tasks for each ECS service"
  type        = number
  default     = 1
}


