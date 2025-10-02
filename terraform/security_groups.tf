module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"


  name        = "${local.name}-alb-sg"
  description = "ALB SG"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTP from anywhere"
    }
  ]


  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "All egress"
    }
  ]


  tags = local.tags
}


module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"


  name        = "${local.name}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id


  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
      description              = "ALB to ECS"
    }
  ]


  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "All egress"
    }
  ]


  tags = local.tags
}
