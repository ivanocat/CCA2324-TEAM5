module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "172.31.0.0/16"

  azs              = ["${var.region}a", "${var.region}b"]
  public_subnets   = ["172.31.0.0/24", "172.31.1.0/24"]
  private_subnets  = ["172.31.10.0/24", "172.31.11.0/24"]
  database_subnets = ["172.31.12.0/24", "172.31.13.0/24"]

  enable_vpn_gateway = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }

  igw_tags = {
    Name = "${var.prefix}-igw"
  }

  nat_gateway_tags = {
    Name = "${var.prefix}-natgw"
  }
}