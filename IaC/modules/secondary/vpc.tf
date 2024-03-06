module "secondary_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-secondary-vpc"
  cidr = var.secondary_vpc_cidr

  azs              = ["${var.secondary_region}a", "${var.secondary_region}b"]
  public_subnets   = ["172.31.1.0/24", "172.31.2.0/24"] // Implies Internet Gateway creation
  private_subnets  = ["172.31.11.0/24", "172.31.12.0/24"]
  database_subnets = ["172.31.21.0/24", "172.31.22.0/24"]

  // One NAT Gateway per AZ
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }

  igw_tags = {
    Name = "${var.prefix}-secondary-igw"
  }

  nat_gateway_tags = {
    Name = "${var.prefix}-secondary-natgw"
  }
}