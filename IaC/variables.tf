variable "region" {
  description = "The selected AWS region for the VPC"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain reserved at https://dnsexit.com/"
  type        = string
  default     = "pfp-team5.com"
}