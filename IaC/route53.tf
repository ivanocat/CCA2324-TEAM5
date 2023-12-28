# Hosting Zone
resource "aws_route53_zone" "primary" {
  name    = var.domain
  comment = "Domain for the team 5's PFP"
}
