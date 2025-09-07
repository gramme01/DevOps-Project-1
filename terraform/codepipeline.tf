resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = "${var.project_name}-codepipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = local.tags
}


resource "aws_s3_bucket_ownership_controls" "pipeline" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  rule { object_ownership = "BucketOwnerPreferred" }
}


resource "aws_s3_bucket_public_access_block" "pipeline" {
  bucket                  = aws_s3_bucket.pipeline_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# CodeStar connection to GitHub 
# TODO: - I dont think I should have to recreate this every time
# TODO: Autorization via console needed 
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name}-github"
  provider_type = "GitHub"
}


# CodeBuild project for BUILD (docker build & push)
resource "aws_codebuild_project" "build" {
  name          = "${local.name}-build"
  service_role  = aws_iam_role.codebuild_build_role.arn
  build_timeout = 30
  
  artifacts {
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "ECR_REPO_URL"
      value = module.ecr.repository_url
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/codebuild/${local.name}-build"
    }
  }

  source {
    type         = "CODEPIPELINE"
    buildspec    = file("${path.module}/../buildspecs/buildspec-build.yml")
    insecure_ssl = false
  }

  tags = local.tags
}


# CodeBuild project for TEST
resource "aws_codebuild_project" "test" {
  name          = "${local.name}-test"
  service_role  = aws_iam_role.codebuild_test_role.arn
  build_timeout = 20


  artifacts {
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/codebuild/${local.name}-test"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspecs/buildspec-test.yml")
  }

  tags = local.tags
}


# ========
# CodePipeline
# ========

resource "aws_codepipeline" "this" {
  name     = "${local.name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn


  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }


  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
        DetectChanges    = true
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "Docker_Build_Push"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }


  stage {
    name = "Test"
    action {
      name             = "Unit_Tests"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["test_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.test.name
      }
    }
  }


  stage {
    name = "Deploy"
    action {
      name            = "ECS_Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ClusterName = module.ecs.cluster_name
        ServiceName = module.ecs_service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }


  tags = local.tags
}