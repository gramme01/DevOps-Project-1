module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"


  cluster_name = local.name

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
    }
  }

  tags = local.tags
}

########################
# Service

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 6.0"


  name        = "${local.name}-svc"
  cluster_arn = module.ecs.cluster_arn


  cpu    = var.cpu
  memory = var.memory

  create_task_exec_iam_role = false
  create_tasks_iam_role     = false


  task_exec_iam_role_arn = aws_iam_role.ecs_task_execution.arn
  tasks_iam_role_arn      = aws_iam_role.ecs_task_role.arn


  # launch_type = "FARGATE"
  # assign_public_ip       = false
  # create_task_definition = true


  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.ecs_sg.security_group_id]


  container_definitions = {
    web = {
      image                  = "${module.ecr.repository_url}:latest" # updated by CodePipeline deploy via imagedefinitions.json
      cpu                    = var.cpu
      memory                 = var.memory
      essential              = true
      portMappings           = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }]
      readonlyRootFilesystem = false


      environment = [
        { name = "PORT", value = tostring(var.container_port) }
      ]

      secrets = [
        {
          name      = "APP_SECRET"
          valueFrom = aws_ssm_parameter.app_secret.arn
        }
      ]
      enable_cloudwatch_logging = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = "/ecs/${local.name}"
          awslogs-stream-prefix = "web"
        }
      }
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ecs"].arn
      container_name   = "web"
      container_port   = var.container_port
  } }


  propagate_tags = "SERVICE"
  tags           = local.tags
}


resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name}"
  retention_in_days = 14
  tags              = local.tags
}
