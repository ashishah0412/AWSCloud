region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
azs = ["us-east-1a", "us-east-1b"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

db_username = "appadmin"
db_password = "ChangeMeSecurely"

ecs_services = ["auth", "policy", "claims", "customer", "notification"]

ui_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/ui:latest"
ecr_repo = "123456789012.dkr.ecr.us-east-1.amazonaws.com"
