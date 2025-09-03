module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.10"


  name                       = local.name
  load_balancer_type         = "application"
  internal                   = false
  vpc_id                     = module.vpc.vpc_id
  enable_deletion_protection = false



  security_groups = [module.alb_sg.security_group_id]
  subnets         = module.vpc.public_subnets


  target_groups = {
    ecs = {
      name_prefix      = "${var.environment}-"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        path                = "/health"
        matcher             = "200"
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
      }
      create_attachment = false
    }
  }



  listeners = {
    http-tcp = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ecs"
      }
    }
  }


  tags = local.tags
}
