terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Note: A backend block cannot refer to named values
  backend "s3" {
    bucket          = "tf-remote-state20240105183740884600000001"
    key             = "pfp-vpc"
    dynamodb_table  = "tf-remote-state-lock"
    region          = "us-east-1"
  }

  required_version = ">= 1.1.5"
}

provider "aws" {
  region = var.region
} 
