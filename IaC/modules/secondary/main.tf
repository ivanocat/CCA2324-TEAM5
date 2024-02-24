provider "aws" {
  region = var.region
}

module "secondary_alb" {
  prefix = "secondary"
  source = "../../modules/alb/"
  vpc_public_subnets = module.secondary_vpc.public_subnets
  web_sg_id = module.secondary_web_sg.security_group_id
  vpc_id = module.secondary_vpc.vpc_id
}

module "secondary_asg" {
  prefix            = "secondary"
  source            = "../../modules/asg"
  max_size          = 0
  min_size          = 0
  desired_capacity  = 0
  ami_id            = var.secondary_instance_ami
  app_security_group = module.secondary_app_sg.security_group_id
  vpc_zone_identifier = module.secondary_vpc.private_subnets
  target_group_arn = module.secondary_alb.target_group_arn
  bd_address = module.rds-read-replica.db_replica_address
}

module "secondary-ec2-monitoring" {
  prefix = "secondary"
  source = "../../modules/monitoring"
  intance_type = "t3.medium"
  intance_ami = var.secondary_instance_ami
  vpc_id = module.secondary_vpc.vpc_id
  vpc_public_subnet = module.secondary_vpc.public_subnets[0]
}

module "seconday_waf" {
  prefix = "secondary"
  source = "../../modules/waf"
}

resource "aws_wafv2_web_acl_association" "secondary-waf-association" {
  resource_arn = module.secondary_alb.application_load_balancer_arn
  web_acl_arn  = module.seconday_waf.wafv2_web_acl_arn

  depends_on = [module.secondary_alb.application_load_balancer]
}

module "rds-read-replica" {
  source = "../../modules/read-replica-rds/"
  db_source_indentifier = module.primary.primary_db_identifier
  database_subnets = [module.secondary_vpc.database_subnets[0], module.secondary_vpc.database_subnets[1]]
}