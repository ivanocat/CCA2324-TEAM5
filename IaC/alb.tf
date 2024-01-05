resource "aws_alb" "application_load_balancer" {
  name               = "dev-pfp-team5-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [for subnet in aws_subnet.public : subnet.id]
  security_groups = [aws_security_group.web.id]

  tags = {
      Name        = "pfp-team5-alb"
      Environment = "dev",
      Owner       = "Team 5"
      Project     = "CCA2324-PFP"
    }
}

resource "aws_alb_target_group" "alb_tg" {
  name_prefix = "alb-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
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
      Name        = "dev-pfp-team5-alb-target-group"
      Environment = "dev",
      Owner       = "Team 5",
      Project     = "CCA2324-PFP"
    }
}

resource "aws_alb_listener" "application_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    type             = "forward"
  }
}