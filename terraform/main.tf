terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.0.4"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = "ap-northeast-1"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "profile" {
  type = string
}

data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.*.s3"
}
