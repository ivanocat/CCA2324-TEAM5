output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "web_subnets_id" {
  description = "Web (public) subnets id"
  value       = module.vpc.public_subnets
}

output "app_subnets_id" {
  description = "Application (private) subnets id"
  value       = module.vpc.private_subnets
}

output "data_subnets_id" {
  description = "Database (private) subnets id"
  value       = module.vpc.database_subnets
}

output "auto_scaling_group_name" {
  description = "Auto scaling group name"
  value       = aws_autoscaling_group.application_asg.name
}

output "load_balancer_dns_name" {
  description = "LoadBalancer dns name"
  value       = aws_alb.application_load_balancer.dns_name
}

output "auto_scaling_group_tg_arn" {
  description = "ASG target group arn"
  value       = aws_alb_target_group.asg_tg.arn
}

output "monitoring_tg_arn" {
  description = "Monitoring target group arn"
  value       = aws_alb_target_group.monitoring_tg.arn
}

output "launch_template_id" {
  description = "Launch template id"
  value       = aws_launch_template.application_lt.id
}
