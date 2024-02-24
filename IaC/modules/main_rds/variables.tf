variable "database_subnets" {
  description = "IAM instance profile role"
  type        = set(string)
}

variable "data_sg_id" {
  description = "VPC public subnets"
  type        = set(string)
}
