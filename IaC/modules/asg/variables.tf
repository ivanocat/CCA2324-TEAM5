variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
  default     = "dr-poc"
}

variable "lab_instance_role" {
  description = "IAM instance profile role"
  type        = string
  default     = "LabInstanceProfile"
}

variable "vpc_zone_identifier" {
  description = "VPC zone identifier"
  type = set(string)
}

variable "ami_id" {
  description = "AMI ID for launch template"
  type        = string
}

variable "app_security_group" {
  description = "Application SG"
  type        = string
}

variable "max_size" {
  description = "Maximum size of ASG"
  type        = number
}

variable "min_size" {
  description = "Minimum size of ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of ASG"
  type        = number
}

variable "instance_type" {
  description = "Tipo de instancia para la instancia principal"
  default     = "t3.medium"
  type        = string
}

variable "target_group_arn" {
  description = "Alb target group arn"
  type = string
}

variable "bd_address" {
  description = "RDS endpoint"
  type = string
}