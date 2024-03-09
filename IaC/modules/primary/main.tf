provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Owner       = "Team 5"
      Project     = "CCA2324-PFP"
    }
  }
}

module "primary_alb" {
  prefix             = "primary"
  source             = "../../modules/alb"
  vpc_public_subnets = module.primary_vpc.public_subnets
  web_sg_id          = module.primary_web_sg.security_group_id
  vpc_id             = module.primary_vpc.vpc_id
}

module "primary_asg" {
  prefix              = "primary"
  source              = "../../modules/asg"
  max_size            = 2
  min_size            = 2
  desired_capacity    = 2
  ami_id              = var.primary_instance_ami
  app_security_group  = module.primary_app_sg.security_group_id
  vpc_zone_identifier = module.primary_vpc.private_subnets
  target_group_arn    = module.primary_alb.target_group_arn
  rds_dependency      = aws_db_instance.postgres_odoo
  bd_address          = aws_db_instance.postgres_odoo.address
}

module "primary-ec2-monitoring" {
  prefix            = "primary"
  source            = "../../modules/monitoring"
  intance_type      = "t3.medium"
  intance_ami       = "ami-0c7217cdde317cfec"
  vpc_id            = module.primary_vpc.vpc_id
  vpc_public_subnet = module.primary_vpc.public_subnets[0]
  secrets_path      = "${path.module}/secrets"
  ec2_name          = "primary-asg"
}

module "primary_waf" {
  prefix = "primary"
  source = "../../modules/waf"
}

resource "aws_wafv2_web_acl_association" "primary-waf-association" {
  resource_arn = module.primary_alb.application_load_balancer_arn
  web_acl_arn  = module.primary_waf.wafv2_web_acl_arn

  depends_on = [module.primary_alb.application_load_balancer]
}

resource "aws_route53_health_check" "primary" {
  failure_threshold = 3
  fqdn              = module.primary_alb.application_load_balancer.dns_name
  port              = 80
  request_interval  = 30
  type              = "HTTP"
}

resource "aws_route53_record" "primary_failover_record" {
  zone_id        = var.route53_zone_id
  name           = "www.pfp-team5.com"
  type           = "CNAME"
  ttl            = 60
  set_identifier = "primary-failover"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary.id

  records = [module.primary_alb.application_load_balancer.dns_name]
}