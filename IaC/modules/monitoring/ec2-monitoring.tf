locals {
  userdata_script = templatefile("${path.module}/scripts/ec2-monitoring.sh", { ec2_name_ext = var.ec2_name })
}

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

  ami                         = var.intance_ami
  instance_type               = var.intance_type
  key_name                    = aws_key_pair.kp.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.monitoring_sg.security_group_id]
  subnet_id                   = var.vpc_public_subnet
  associate_public_ip_address = true
  iam_instance_profile        = var.lab_instance_role

  user_data  = base64encode(local.userdata_script)

  tags = {
    Name        = "${var.prefix}-monitoring"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}
