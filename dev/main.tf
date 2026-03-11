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

locals {
  environment = "dev"
}

module "terrask8s_vpc" {
  source = "../modules/terrask8s/vpcs"

  cidr_block  = "10.0.1.0/24"
  environment = local.environment
  az_count    = 3
}

module "terrask8s_security" {
  source                  = "../modules/terrask8s/security"
  vpc_id                  = module.terrask8s_vpc.vpc_id
  allowed_ssh_cidr_blocks = ["${var.home_office_ip}/32"]
  environment             = local.environment
}

module "terrask8s_services" {
  source             = "../modules/terrask8s/services"
  environment        = local.environment
  ami_id             = var.ami_id
  subnet_ids         = module.terrask8s_vpc.subnet_ids
  security_group_ids = [module.terrask8s_security.security_group_id]
  key_name           = var.key_name
}

output "node_ssh_commands" {
  description = "SSH commands for each node"
  value = [
    for i, ip in module.terrask8s_services.public_ips :
    "node #${i}: ssh -i ~/.ssh/${var.key_name}.pem admin@${ip}"
  ]
}
