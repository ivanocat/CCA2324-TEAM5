resource "aws_alb" "application_load_balancer" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = var.vpc_public_subnets
  security_groups = [var.web_sg_id]

  tags = {
    Name        = "${var.prefix}-alb"
    Environment = "dev",
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

resource "aws_alb_target_group" "asg_tg" {
  name        = "${var.prefix}-asg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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

resource "aws_alb_listener" "asg_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.asg_tg.arn
    type             = "forward"
  }
}