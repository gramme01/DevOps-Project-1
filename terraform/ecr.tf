module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.0"


  repository_name         = local.name
  repository_image_tag_mutability = "MUTABLE"
  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 20 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 20
        },
        action = { type = "expire" }
      }
    ]
  })


  tags = local.tags
}
