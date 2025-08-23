terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  project_name       = var.project_name
  env                = var.env

}
