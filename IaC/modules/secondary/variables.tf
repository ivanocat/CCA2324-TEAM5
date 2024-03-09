variable "region" {
  description = "The AWS region in which resources are set up."
  type        = string
  default     = "us-west-2"
}

variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
  default     = "pfp"
}

variable "lab_instance_role" {
  description = "IAM instance profile role"
  type        = string
  default     = "LabInstanceProfile"
}

variable "secondary_region" {
  description = "Región secundaria de AWS"
  default     = "us-west-2"
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "CIDR para la VPC secundaria"
  default     = "172.31.0.0/16"
  type        = string
}

variable "secondary_instance_ami" {
  description = "ID de la AMI para la instancia principal de la VPC secundaria"
  default     = "ami-01e82af4e524a0aa3" // Amazon Linux 2023 AMI 2023.3.20240205.2 x86_64 HVM kernel-6.1
  type        = string
}

variable "secondary_instance_type" {
  description = "Tipo de instancia para la instancia principal de la VPC secundaria"
  default     = "t2.micro"
  type        = string
}

variable "main_rds" {
  description = "Main RDS resource"
  type        = any
}

variable "route53_zone_id" {
  description = "Route53 Zone identifier"
  type        = string
}
