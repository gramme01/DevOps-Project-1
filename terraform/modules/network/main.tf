#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
#tfsec:ignore:aws-ec2-no-public-ip-subnet

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-vpc"
  cidr = var.cidr_block

  azs             = var.availability_zones
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.cidr_block, 8, k)]
  public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.cidr_block, 8, k + 2)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project     = "${var.project_name}-vpc"
    Environment = var.env
  }
}
