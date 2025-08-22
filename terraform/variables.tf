variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "project_name" {
  type    = string
  default = "DevOps Assessment 1"
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