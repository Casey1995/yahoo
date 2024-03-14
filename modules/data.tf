data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  backend "local" {
    path = terraform.tfstate
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}