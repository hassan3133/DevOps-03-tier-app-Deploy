locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

variable "aws_region" {
  default = "eu-north-1"
}

variable "environment" {
  default = "prod"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
}

# variable "private_subnets_cidr" {
#   type        = list(any)
#   default     = ["10.0.16.0/20", "10.0.144.0/20"]
#   description = "CIDR block for Private Subnet"
# }