# DevOps Assessment: Terraform + CodePipeline + ECS (Node on Fargate)


This repository provisions a complete CI/CD pipeline:


- **Terraform** creates: VPC, public/private subnets, **internet-facing ALB**, ECS cluster & Fargate service, Security Groups, ECR, SSM Parameter(s), and a 3-stage **CodePipeline** (Source → Build → Test → Deploy) using CodeBuild and ECS deploy action.
- **Node app** listens on **port 3000** with `/` and `/health`.
- **CodeBuild** builds & pushes the Docker image to ECR and produces `imagedefinitions.json` for ECS deployment.


## Prerequisites
- Terraform >= 1.6, AWS CLI configured.
- Create/authorize **CodeStar Connection** during first `terraform apply` (a console one-time click is required to connect GitHub).


## Quick Start


1. **Clone repo** and set variables (either `terraform.tfvars` or CLI flags). Below is an example.


```hcl
aws_region          = "us-east-1"
availability_zones  = ["us-east-1a", "us-east-1b"]
cidr_block          = "10.0.0.0/16"
project_name        = "project1"
environment         = "dev" # or "prod"
github_repo         = "YOUR_GITHUB_OWNER/YOUR_REPO"
github_branch       = "main" # or "CI branch"
app_secret_value    = "change-me"