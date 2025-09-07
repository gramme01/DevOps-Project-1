variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "project_name" {
  type    = string
  default = "assessment-one"
}

variable "cidr_block" {
  description = "VPC CIDR block. Example: 10.10.0.0/16"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  type = list(any)
}


################
# Container variables

variable "container_port" {
  type    = number
  default = 3000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 2
}


#####
# SSM

variable "app_secret_value" {
  type        = string
  description = "App Secret Key"
}



#####
# CI/CD
variable "github_repo" {
  type        = string
  description = "The GitHub repository name (e.g., user/repo)"
}
variable "github_branch" {
  type        = string
  description = "The GitHub branch to use for the pipeline"
  default     = "main"

}