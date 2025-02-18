provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "The AWS region to deploy the infrastructure"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  default     = "demo"
}

variable "owner" {
  description = "Owner of the resources"
  default     = "steve.stickel"
}