locals {
  asg_tags = {
    Name = "${var.prefix}-asg"
  }
}

locals {
  userdata_script = templatefile("${path.module}/scripts/ec2-userdata.sh", { db_address_ext = aws_db_instance.postgres_odoo.address })
}

resource "aws_launch_template" "application_lt" {
  name_prefix   = "${var.prefix}-launch-template"
  image_id      = "ami-0a3c3a20c09d6f377" // Amazon Linux 2023 AMI (64-bit (x86), uefi-preferred)
  instance_type = "t3.medium"

  // EC2 role
  iam_instance_profile {
    name = var.lab_instance_role
  }

  // Detailed monitoring
  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [module.app_sg.security_group_id]
  }

  user_data = base64encode(local.userdata_script)

  // Detailed depends on
  depends_on = [aws_db_instance.postgres_odoo]
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
  name                      = "${var.prefix}-cpu-scaling-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 10 //optional. Without a value, AWS will default to the group's specified cooldown period (300s).
  autoscaling_group_name    = aws_autoscaling_group.application_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}

resource "aws_autoscaling_attachment" "application_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.application_asg.name
  lb_target_group_arn    = aws_alb_target_group.asg_tg.arn
}
