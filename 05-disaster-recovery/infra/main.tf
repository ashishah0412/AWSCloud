provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Primary Region Resources
resource "aws_vpc" "primary" {
  provider   = aws.primary
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-primary-vpc"
  }
}

resource "aws_subnet" "primary_public" {
  provider          = aws.primary
  count             = 2
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "${var.primary_region}${local.az_suffixes[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-primary-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "primary" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  tags = {
    Name = "${var.project_name}-primary-igw"
  }
}

resource "aws_route_table" "primary_public" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }

  tags = {
    Name = "${var.project_name}-primary-public-rt"
  }
}

resource "aws_route_table_association" "primary_public" {
  provider       = aws.primary
  count          = 2
  subnet_id      = aws_subnet.primary_public[count.index].id
  route_table_id = aws_route_table.primary_public.id
}

resource "aws_s3_bucket" "primary_app_data" {
  provider = aws.primary
  bucket   = "${var.project_name}-primary-app-data-${random_string.bucket_suffix.id}"

  tags = {
    Name = "${var.project_name}-primary-app-data"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_s3_bucket_versioning" "primary_app_data_versioning" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary_app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "primary_app_data_replication" {
  provider = aws.primary
  role     = aws_iam_role.s3_replication_role.arn
  bucket   = aws_s3_bucket.primary_app_data.id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary_app_data.arn
      storage_class = "STANDARD"
      replica_kms_key_id = ""
    }
  }
}

resource "aws_iam_role" "s3_replication_role" {
  provider = aws.primary
  name     = "${var.project_name}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-s3-replication-role"
  }
}

resource "aws_iam_role_policy" "s3_replication_policy" {
  provider = aws.primary
  name     = "${var.project_name}-s3-replication-policy"
  role     = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = aws_s3_bucket.primary_app_data.arn
      },
      {
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.primary_app_data.arn}/*"
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.secondary_app_data.arn}/*"
      }
    ]
  })
}

resource "aws_db_subnet_group" "primary" {
  provider   = aws.primary
  name       = "${var.project_name}-primary-db-subnet-group"
  subnet_ids = aws_subnet.primary_public[*].id # Using public for simplicity, ideally private

  tags = {
    Name = "${var.project_name}-primary-db-subnet-group"
  }
}

resource "aws_db_instance" "primary" {
  provider             = aws.primary
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t3.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.primary.name
  skip_final_snapshot  = true
  multi_az             = true
  publicly_accessible  = true # For simplicity, ideally false and accessed via bastion/VPN

  tags = {
    Name = "${var.project_name}-primary-rds-instance"
  }
}

# Secondary Region Resources
resource "aws_vpc" "secondary" {
  provider   = aws.secondary
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "${var.project_name}-secondary-vpc"
  }
}

resource "aws_subnet" "secondary_public" {
  provider          = aws.secondary
  count             = 2
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.${count.index}.0/24"
  availability_zone = "${var.secondary_region}${local.az_suffixes[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-secondary-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "secondary" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  tags = {
    Name = "${var.project_name}-secondary-igw"
  }
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }

  tags = {
    Name = "${var.project_name}-secondary-public-rt"
  }
}

resource "aws_route_table_association" "secondary_public" {
  provider       = aws.secondary
  count          = 2
  subnet_id      = aws_subnet.secondary_public[count.index].id
  route_table_id = aws_route_table.secondary_public.id
}

resource "aws_s3_bucket" "secondary_app_data" {
  provider = aws.secondary
  bucket   = "${var.project_name}-secondary-app-data-${random_string.bucket_suffix.id}"

  tags = {
    Name = "${var.project_name}-secondary-app-data"
  }
}

resource "aws_s3_bucket_versioning" "secondary_app_data_versioning" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary_app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_db_subnet_group" "secondary" {
  provider   = aws.secondary
  name       = "${var.project_name}-secondary-db-subnet-group"
  subnet_ids = aws_subnet.secondary_public[*].id # Using public for simplicity, ideally private

  tags = {
    Name = "${var.project_name}-secondary-db-subnet-group"
  }
}

resource "aws_db_instance" "secondary_replica" {
  provider             = aws.secondary
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.secondary.name
  replicate_source_db  = aws_db_instance.primary.identifier
  skip_final_snapshot  = true
  publicly_accessible  = true # For simplicity, ideally false and accessed via bastion/VPN

  tags = {
    Name = "${var.project_name}-secondary-rds-replica"
  }
}

# Route 53 for DNS Failover
resource "aws_route53_zone" "main" {
  name = "${var.project_name}.com."

  tags = {
    Name = "${var.project_name}-route53-zone"
  }
}

resource "aws_route53_record" "app_primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.project_name}.com"
  type    = "A"
  ttl     = 60

  set_identifier = "primary-region"
  failover_routing_policy {
    type = "PRIMARY"
  }

  # This would typically be an ALB or EC2 instance IP in the primary region
  records = ["192.0.2.1"]

  health_check_id = aws_route53_health_check.primary_app_health.id
}

resource "aws_route53_record" "app_secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.project_name}.com"
  type    = "A"
  ttl     = 60

  set_identifier = "secondary-region"
  failover_routing_policy {
    type = "SECONDARY"
  }

  # This would typically be an ALB or EC2 instance IP in the secondary region
  records = ["198.51.100.1"]

  health_check_id = aws_route53_health_check.secondary_app_health.id
}

resource "aws_route53_health_check" "primary_app_health" {
  fqdn              = "primary-app.${var.project_name}.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-primary-app-health-check"
  }
}

resource "aws_route53_health_check" "secondary_app_health" {
  fqdn              = "secondary-app.${var.project_name}.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-secondary-app-health-check"
  }
}

locals {
  az_suffixes = ["a", "b", "c", "d", "e", "f"]
}


