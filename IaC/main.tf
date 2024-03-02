resource "aws_route53_zone" "main" {
  name = var.domain
}

module "primary" {
  source          = "./modules/primary"
  route53_zone_id = aws_route53_zone.main.zone_id
}

module "secondary" {
  source          = "./modules/secondary"
  main_rds        = module.primary.primary_rds_resource
  route53_zone_id = aws_route53_zone.main.zone_id
}
