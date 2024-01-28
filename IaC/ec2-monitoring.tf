module "ec2-monitoring" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.prefix}-monitoring"

  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.medium"
  key_name                    = "pfp"
  monitoring                  = true
  vpc_security_group_ids      = [module.monitoring_sg.security_group_id,module.web_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"

  user_data = filebase64("./scripts/ec2-monitoring.sh")

  tags = {
    Name        = "${var.prefix}-monitoring"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}