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

variable "vpc-cidr" {
  description = "The address range of the VPC"
  type        = string
  default     = "172.31.0.0/16"
}

variable "min-az" {
  description = "The minimum AZ to be used"
  type        = number
  default     = 2
}

variable "domain" {
  description = "Domain reserved at https://dnsexit.com/"
  type        = string
  default     = "cca2324-team5.work.gd"
}
