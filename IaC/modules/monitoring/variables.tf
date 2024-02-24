variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
}

variable "lab_instance_role" {
  description = "IAM instance profile role"
  type        = string
  default     = "LabInstanceProfile"
}

variable "vpc_id" {
    description = "VPC id"
    type = string
}

variable "intance_ami" {
    description = "EC2 instance image"
    type = string
}

variable "intance_type" {
    description = "EC2 instance type"
    type = string
}

variable "vpc_public_subnet" {
    description = "VPC public subnet allocation"
    type = string
}
