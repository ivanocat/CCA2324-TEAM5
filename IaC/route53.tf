resource "aws_route53_zone" "main" {
  name = "pfp-team5.com"
}

resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.pfp-team5.com"
  type    = "CNAME"
  ttl     = 86400  # 24 horas en segundos

  records = [
    aws_alb.application_load_balancer.dns_name
  ]
}

