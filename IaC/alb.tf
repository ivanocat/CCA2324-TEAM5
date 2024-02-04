resource "aws_alb" "application_load_balancer" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = module.vpc.public_subnets
  security_groups = [module.web_sg.security_group_id]

  tags = {
    Name        = "${var.prefix}-alb"
    Environment = "dev",
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

resource "aws_alb_target_group" "asg_tg" {
  name_prefix = "asg-"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  load_balancing_algorithm_type = "round_robin"

  tags = {
    Name        = "${var.prefix}-asg-tg"
    Environment = "dev",
    Owner       = "Team 5",
    Project     = "CCA2324-PFP"
  }
}

resource "aws_alb_target_group" "monitoring_tg" {
  name_prefix = "monit-"
  port        = "3000"
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "3000"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  load_balancing_algorithm_type = "round_robin"

  tags = {
    Name        = "${var.prefix}-monitoring-tg"
    Environment = "dev",
    Owner       = "Team 5",
    Project     = "CCA2324-PFP"
  }
}

resource "aws_alb_target_group_attachment" "monitoring_tg_attachment" {
  target_group_arn = aws_alb_target_group.monitoring_tg.arn
  target_id        = module.ec2-monitoring.id
  port             = 3000
}

resource "aws_alb_listener" "asg_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.asg_tg.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "monitoring_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.monitoring_tg.arn
    type             = "forward"
  }
}