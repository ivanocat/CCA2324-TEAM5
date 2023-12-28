terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "remote_state" {
  source  = "nozaq/remote-state-s3-backend/aws"
  version = "1.5.0"

  terraform_iam_policy_create = false

  # Academy doesn't allow S3 replication
  enable_replication = false

  providers = {
    aws         = aws
    aws.replica = aws
  }
}
