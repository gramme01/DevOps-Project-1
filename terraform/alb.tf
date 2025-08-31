module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.10"


  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false


  security_groups = [module.alb_sg.security_group_id]
  subnets         = module.vpc.public_subnets


  target_groups = [
    {
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
    }
  ]

  #   http_tcp_listeners = [
  #     {
  #       port               = 80
  #       protocol           = "HTTP"
  #       target_group_index = 0
  #     }
  #   ]

  listeners = {
    http-tcp = {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0

    }
  }


  tags = local.tags
}
