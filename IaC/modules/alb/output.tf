output "target_group_arn" {
  description = "Target Group id (arn)"
  value       = aws_alb_target_group.asg_tg.arn
}

output "load_balancer_address" {
  description = "Application Load Balancer public DNS address"
  value       = aws_alb.application_load_balancer.dns_name
}

output "auto_scaling_group_tg_id" {
  description = "Auto-scaling Group, Target Group id (arn)"
  value       = aws_alb_target_group.asg_tg.id
}

output "alb_listeners_port" {
  description = "ALB's listening to port"
  value       = "Port ${aws_alb_listener.asg_listener.port} -> Odoo"
}

output "application_load_balancer" {
  description = "Application Load Balancer"
  value       = aws_alb.application_load_balancer
}

output "application_load_balancer_arn" {
  description = "ALB arn"
  value       = aws_alb.application_load_balancer.arn
}