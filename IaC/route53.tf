# Hosting Zone
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.domain}" = {
      comment = "${var.domain}"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name = "${var.prefix}"
      type = "A"
      alias = {
        name                   = aws_alb.application_load_balancer.dns_name
        zone_id                = aws_alb.application_load_balancer.zone_id
        evaluate_target_health = true
      }
    }
  ]

  depends_on = [module.zones]
}
