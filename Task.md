# DevOps Assessment: Terraform + CodePipeline + ECS

## Overview
Create a complete CI/CD pipeline that deploys a Django application to ECS using Terraform for infrastructure provisioning and AWS CodePipeline for automated deployment.

## Assessment Requirements
### 1. Infrastructure (Terraform)
Create Terraform configuration to provision:
- ECS Cluster using the official HashiCorp ECS module
- Application Load Balancer with target groups. Make the ALB internet facing
- VPC with public/private subnets
- Security Groups with appropriate rules. Django listens on port 8000
- IAM roles for ECS tasks and CodePipeline
- ECR repository for container images
- Parameter store entries for application secrets

2. Application Code
Create a simple Django application with:
Welcome screen displaying "Hello DevOps Assessment!"
Health check endpoint (/health)
Basic unit tests using pytest
Dockerfile for containerization
requirements.txt with dependencies

3. CI/CD Pipeline (CodePipeline)
Implement a 3-stage pipeline:
Build Stage
Pull source code from the repository. You can connect your github repo as a source point
Build Docker image using a Dockerfile. I will provide a sample codebase via Github which has the entire Django application. Your focus is just using the codefiles to create your Dockerfile
Tag and push image to ECR
Generate build artifacts
Test Stage
Run pytest tests against the application
Generate test reports
Fail pipeline if tests don't pass
Deploy Stage
Deploy to ECS cluster created by Terraform
Update ECS service with new image
Perform health checks
