module "ec2-monitoring" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.prefix}-monitoring"

  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.kp.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.monitoring_sg.security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  iam_instance_profile        = var.lab_instance_role

  user_data = filebase64("./scripts/ec2-monitoring.sh")

  tags = {
    Name        = "${var.prefix}-monitoring"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

################################################################################
# Supporting Resources
################################################################################

module "monitoring_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-monitoring-sg"
  description = "Allow TCP ports for Monitoring"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.web_sg.security_group_id // Includes port 3000
    }
  ]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp", "prometheus-http-tcp"] // Ports 22, 9090

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