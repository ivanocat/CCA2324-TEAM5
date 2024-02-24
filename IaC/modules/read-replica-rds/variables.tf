variable "db_source_indentifier" {
  description = "DB source identifier"
  type        = string
}

variable "database_subnets" {
  description = "IAM instance profile role"
  type        = set(string)
}
