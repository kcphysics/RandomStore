terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
    dev_certificate_arn = "arn:aws:acm:us-east-1:950094899988:certificate/f2eb11ff-d3b3-4941-8497-a189a51f1873"
    lambda_name = "devRandomStoreBackend"
    cors_orgins = [
        "*",
    ]
}
