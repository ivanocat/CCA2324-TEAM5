output "auto_scaling_group_id" {
  description = "Auto-scaling Group name"
  value       = aws_autoscaling_group.application_asg.id
}

output "launch_template_id" {
  description = "Launch Template id"
  value       = aws_launch_template.application_lt.id
}