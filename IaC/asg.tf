locals {
  asg_tags = { 
    Name = "dev-pfp-team5-asg"
    }
}


resource "aws_launch_template" "application_lt" {
  name_prefix   = "dev-pfp-team5-launch_template"
  image_id      = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode()

}

resource "aws_autoscaling_group" "application_asg" {
  name                = "dev-pfp-team5-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  launch_template {
    id      = aws_launch_template.application_lt.id
    version = "$Latest" //aws_launch_template.application_lt.latest_version
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }


}

resource "aws_autoscaling_policy" "cpu_scaling_policy" {
  name                   = "dev-pfp-team5-cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 10 //optional. Without a value, AWS will default to the group's specified cooldown period (300s).
  autoscaling_group_name = aws_autoscaling_group.application_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}


resource "aws_autoscaling_attachment" "application_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.application_asg.name
  lb_target_group_arn    = aws_alb_target_group.alb_tg.arn
}