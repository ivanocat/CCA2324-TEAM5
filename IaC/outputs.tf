# Network-related outputs
output "vpc_id" {
  description = "Virtual Private Cloud id"
  value       = module.vpc.vpc_id
}

output "web_subnets_id" {
  description = "Web (public) subnets ids"
  value       = module.vpc.public_subnets
}

output "app_subnets_id" {
  description = "Application (private) subnets ids"
  value       = module.vpc.private_subnets
}

output "data_subnets_id" {
  description = "Database (private) subnets ids"
  value       = module.vpc.database_subnets
}

# ASG-related outputs
output "auto_scaling_group_id" {
  description = "Auto-scaling Group name"
  value       = aws_autoscaling_group.application_asg.id
}

output "launch_template_id" {
  description = "Launch Template id"
  value       = aws_launch_template.application_lt.id
}

# ALB-related outputs
output "load_balancer_address" {
  description = "Application Load Balancer public DNS address"
  value       = aws_alb.application_load_balancer.dns_name
}

output "auto_scaling_group_tg_id" {
  description = "Auto-scaling Group, Target Group id (arn)"
  value       = aws_alb_target_group.asg_tg.id
}

output "monitoring_tg_id" {
  description = "Monitoring EC2, Target Group id (arn)"
  value       = aws_alb_target_group.monitoring_tg.id
}

output "alb_listeners_port" {
  description = "ALB's listening to ports"
  value       = [ "Port ${aws_alb_listener.asg_listener.port} -> Odoo", "Port ${aws_alb_listener.monitoring_listener.port} -> Grafana" ]
}

# WAF-related outputs
output "waf_id" {
  description = "Web Application Firewall id"
  value       = aws_wafv2_web_acl.waf.id
}

