module "primary_web_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-web-sg"
  description = "Security group for web-server with HTTP ports open within the primary VPC"
  vpc_id      = module.primary_vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "all-icmp", "grafana-tcp"] // Grafana-TCP = 3000

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

module "primary_app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-app-sg"
  description = "Security group for app chained with primary vpc web_sg"
  vpc_id      = module.primary_vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.primary_web_sg.security_group_id
    }
  ]
  ingress_cidr_blocks = [module.primary_vpc.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp", "prometheus-node-exporter-http-tcp"] // Ports 22, 9100

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

module "primary_data_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-data-sg"
  description = "Security group for data chained with primary VPC app_sg"
  vpc_id      = module.primary_vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.primary_app_sg.security_group_id
    }
  ]
  ingress_cidr_blocks = [module.primary_vpc.vpc_cidr_block]
  ingress_rules       = ["postgresql-tcp"] // Port 5432

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}