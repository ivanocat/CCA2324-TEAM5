locals {
  asg_tags = { 
    Name = "${var.prefix}-asg"
    }
}


resource "aws_launch_template" "application_lt" {
  name_prefix   = "${var.prefix}-launch_template"
  image_id      = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.web_sg.security_group_id]
  }

  user_data = filebase64("./scripts/ec2-userdata.sh")

}

resource "aws_autoscaling_group" "application_asg" {
  name                = "${var.prefix}-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = module.vpc.private_subnets

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
  name                   = "${var.prefix}-cpu-scaling-policy"
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