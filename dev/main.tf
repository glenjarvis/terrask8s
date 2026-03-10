terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  #  backend "s3" {
  #    bucket = "<bucket name>"
  #    key    = "<see output>"
  #    region = "<see output>"
  #
  #    dynamodb_table = "terraform-lock"
  #    encrypt        = true
  #  }
}

provider "aws" {
  # region = "choose-region"
}

module "terrask8s_vpc" {
  source = "../modules/terrask8s/vpcs"

  cidr_block = "10.0.1.0/24"
  environment = "dev"
  az_count = 3
}

module "terrask8s_security" {
  source = "../modules/terrask8s/security"
  vpc_id = module.terrask8s_vpc.vpc_id
  allowed_ssh_cidr_blocks = ["${var.home_office_ip}/32"]
  environment = "dev"
}
