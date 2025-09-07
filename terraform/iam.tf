# ===
# ECS Task Execution Role
# ===

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.name}-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



# ===
# ECS Task Role - for accessing SSM Parameter Store
# ===
resource "aws_iam_policy" "ecs_ssm_read" {
  name = "${local.name}-ecs-ssm-read"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory"],
        Resource = [aws_ssm_parameter.app_secret.arn],
        Effect   = "Allow"
      },
      {
        Action   = ["kms:Decrypt"],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_ssm_read.arn
}



# === 
# Task Definition - Execution Role
# ===
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}


# === 
# CodeBuild Role (builder)
# ===
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_build_role" {
  name               = "${local.name}-cb-build"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

resource "aws_iam_role_policy" "codebuild_build_policy" {
  name = "${local.name}-cb-build-policy"
  role = aws_iam_role.codebuild_build_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:BatchCheckLayerAvailability", "ecr:CompleteLayerUpload", "ecr:DescribeRepositories", "ecr:BatchGetImage", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart"], Resource = module.ecr.repository_arn },
      { Effect = "Allow", Action = ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"], Resource = [aws_s3_bucket.pipeline_artifacts.arn, "${aws_s3_bucket.pipeline_artifacts.arn}/*"] },
      { Effect = "Allow", Action = ["sts:GetCallerIdentity"], Resource = "*" }
    ]
  })
}


# === 
# CodeBuild Role (tester)
# === 
resource "aws_iam_role" "codebuild_test_role" {
  name               = "${local.name}-cb-test"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}


resource "aws_iam_role_policy" "codebuild_test_policy" {
  name = "${local.name}-cb-test-policy"
  role = aws_iam_role.codebuild_test_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "*" },
      { Effect = "Allow", Action = ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"], Resource = [aws_s3_bucket.pipeline_artifacts.arn, "${aws_s3_bucket.pipeline_artifacts.arn}/*"] }
    ]
  })
}


# ===
# CodePipeline Role
# ===
resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.name}-cp-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}


data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${local.name}-cp-policy"
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:*"], Resource = [aws_s3_bucket.pipeline_artifacts.arn, "${aws_s3_bucket.pipeline_artifacts.arn}/*"] },
      { Effect = "Allow", Action = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"], Resource = [aws_codebuild_project.build.arn, aws_codebuild_project.test.arn] },
      { Effect = "Allow", Action = ["codestar-connections:UseConnection"], Resource = aws_codestarconnections_connection.github.arn },
      { Effect = "Allow", Action = ["ecs:DescribeServices", "ecs:DescribeTaskDefinition", "ecs:RegisterTaskDefinition", "ecs:UpdateService"], Resource = "*" }
    ]
  })
}