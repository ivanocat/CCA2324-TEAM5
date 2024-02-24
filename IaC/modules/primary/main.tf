provider "aws" {
  region = var.region
}

module "primary_alb" {
  prefix = "primary"
  source = "../../modules/alb"
  vpc_public_subnets = module.primary_vpc.public_subnets
  web_sg_id = module.primary_web_sg.security_group_id
  vpc_id = module.primary_vpc.vpc_id
}

module "primary_asg" {
  prefix            = "primary"
  source            = "../../modules/asg"
  max_size          = 2
  min_size          = 2
  desired_capacity  = 2
  ami_id            = var.primary_instance_ami
  app_security_group = module.primary_app_sg.security_group_id
  vpc_zone_identifier = module.primary_vpc.private_subnets
  target_group_arn = module.primary_alb.target_group_arn
  bd_address = module.primary-rds-odoo.db_address_1
}

module "primary-ec2-monitoring" {
  prefix = "primary"
  source = "../../modules/monitoring"
  intance_type = "t3.medium"
  intance_ami = "ami-0c7217cdde317cfec"
  vpc_id = module.primary_vpc.vpc_id
  vpc_public_subnet = module.primary_vpc.public_subnets[0]
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

module "primary-rds-odoo" {
  source = "../../modules/main_rds"
  data_sg_id = [module.primary_data_sg.security_group_id]
  database_subnets = [module.primary_vpc.database_subnets[0], module.primary_vpc.database_subnets[1]]
}