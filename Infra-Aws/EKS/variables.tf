
variable "aws_region" {
  default = "eu-north-1"
}

variable "environment" {
  default = "prod"
}

variable "subnet_ids" {
  type = list(string)
}