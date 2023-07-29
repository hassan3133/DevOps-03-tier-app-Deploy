variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["10.0.0.0/20", "10.0.128.0/20"]
  description = "CIDR block for Public Subnet"
}

variable "aws_region" {
  default = "eu-north-1"
}

# variable "subnet_ids" {
#   type = list(string)
# }