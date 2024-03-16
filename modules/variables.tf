variable "str_kms_alias" {
}

variable "str_env" {
}

variable "str_application" {
}

variable "map_tags" {
}

variable "region" {
  default = "us-east-1"
}

variable "sns_endpoint" {
  default = "replace with a valid email aggress"
}

variable "subnet_config" {
  default = [
    {"cidr_block" = "10.10.10.0/28", "az" = "us-east-1a"},
    {"cidr_block" = "10.10.10.16/28", "az" = "us-east-1b"}
  ]
}

variable "vpc_cidr" {
}

variable "handshake" {
  type = list
}