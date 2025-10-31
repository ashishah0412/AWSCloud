# -----------------------------
# Network
# -----------------------------
region     = "us-east-1"
vpc_cidr   = "10.0.0.0/16"
azs        = ["us-east-1a", "us-east-1b"]

# -----------------------------
# ECS Cluster
# -----------------------------
ecs_cluster_name = "prod-ecs-cluster"

# -----------------------------
# ALB Certificates (from ACM)
# -----------------------------
ui_cert_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/your-ui-cert-arn"
api_cert_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-api-cert-arn"

# -----------------------------
# ECR and ECS Service Images
# -----------------------------
ecr_repo_prefix = "my-enterprise"

# UI container image (deployed in ECS)
ui_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-ui:latest"

# Backend ECS microservices
ecs_services = {
  "service1" = {
    image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-service1:latest"
    port      = 8081
    cpu       = 256
    memory    = 512
  },
  "service2" = {
    image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-service2:latest"
    port      = 8082
    cpu       = 256
    memory    = 512
  },
  "service3" = {
    image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-service3:latest"
    port      = 8083
    cpu       = 256
    memory    = 512
  },
  "service4" = {
    image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-service4:latest"
    port      = 8084
    cpu       = 256
    memory    = 512
  },
  "service5" = {
    image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-enterprise-service5:latest"
    port      = 8085
    cpu       = 256
    memory    = 512
  }
}

# -----------------------------
# Database
# -----------------------------
db_username = "appadmin"
db_password = "ChangeThis123!"
