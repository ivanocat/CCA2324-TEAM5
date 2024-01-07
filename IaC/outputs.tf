output "load_balancer_dns_name" {
  description = "LoadBalancer dns name"
  value = aws_alb.application_load_balancer.dns_name
}

output "alb_target_group_arn" {
  description = "ALB Target Grouparn"
  value = aws_alb_target_group.alb_tg.arn
}

output "auto_scaling_group_name" {
  description = "Auto scaling group name"
  value = aws_autoscaling_group.application_asg.name
}

output "launch_template_id" {
  description = " launch template id"
  value = aws_launch_template.application_lt.id
}
