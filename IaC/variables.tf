variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
  default     = "pfp"
}

variable "region" {
  description = "The selected AWS region for the VPC"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain reserved at https://dnsexit.com/"
  type        = string
  default     = "cca2324-team5.work.gd"
}

variable "lab_instance_role" {
  description = "IAM instance profile role"
  type        = string
  default     = "LabInstanceProfile"
}