variable "region" {
  description = "The AWS region in which resources are set up."
  type        = string
  default     = "us-east-1"
}

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

variable "primary_region" {
  description = "Región primaria de AWS"
  default     = "us-east-1"
  type        = string
}

variable "primary_vpc_cidr" {
  description = "CIDR para la VPC principal"
  default     = "172.31.0.0/16"
  type        = string
}

variable "primary_instance_ami" {
  description = "ID de la AMI para la instancia principal de la VPC primaria"
  default     = "ami-0e731c8a588258d0d"
  type        = string
}

variable "primary_instance_type" {
  description = "Tipo de instancia para la instancia principal"
  default     = "t2.micro"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Zone identifier"
  type        = string
}