module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-vpc"
  cidr = var.cidr_block

  azs             = var.availability_zones
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.cidr_block, 8, k)]
  public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.cidr_block, 8, k + 4)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


