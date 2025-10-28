variable "aws_region" {
description = "Primary AWS region"
type = string
default = "us-west-2"
}


variable "account_id" {
description = "AWS account id"
type = string
}


variable "project" {
type = string
default = "acsc"
}


variable "vpc_cidr" {
type = string
default = "10.0.0.0/16"
}


variable "public_subnet_cidrs" {
type = list(string)
default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidrs" {
type = list(string)
default = ["10.0.11.0/24", "10.0.12.0/24"]
}


variable "db_subnet_cidrs" {
type = list(string)
default = ["10.0.21.0/24", "10.0.22.0/24"]
}


variable "azs" {
type = list(string)
default = ["a","b"]
}


variable "rds_username" {
type = string
}


variable "rds_password" {
type = string
sensitive = true
}


variable "environment" {
type = string
default = "dev"
}