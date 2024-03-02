variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
}

variable "lab_instance_role" {
  description = "IAM instance profile role"
  type        = string
  default     = "LabInstanceProfile"
}

variable "vpc_public_subnets" {
  description = "VPC public subnets"
  type        = set(string)
}

variable "web_sg_id" {
  description = "Web security group id"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}