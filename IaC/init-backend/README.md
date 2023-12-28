# Terraform remote backend creation

A terraform module to set up remote state management with S3 backend for your account. It creates an encrypted S3 bucket to store state files and a DynamoDB table for state locking and consistency checking.

Based on source: https://github.com/nozaq/terraform-aws-remote-state-s3-backend

:warning: <font color="red">**WARNING:**</font> No need to apply it, since the initial commiter of this file already created the S3 and the DynamoDB table.
