module "monitoring_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-monitoring-sg"
  description = "Allow TCP ports for Monitoring"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "all-icmp", "grafana-tcp", "ssh-tcp", "prometheus-http-tcp"] // Grafana-TCP = 3000, & 22, 9090

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

module "ec2-monitoring" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.prefix}-monitoring"

  ami                         = var.intance_ami//"ami-0c7217cdde317cfec"
  instance_type               = var.intance_type//"t3.medium"
  key_name                    = aws_key_pair.kp.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.monitoring_sg.security_group_id]
  subnet_id                   = var.vpc_public_subnet//module.vpc.public_subnets[0]
  associate_public_ip_address = true
  iam_instance_profile        = var.lab_instance_role

  user_data = filebase64("${path.module}/scripts/ec2-monitoring.sh")

  tags = {
    Name        = "${var.prefix}-monitoring"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}
