resource "aws_cloudwatch_metric_alarm" "route53_health_alarm" {
  alarm_name          = "Route53HealthAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Alarm when the Route 53 health check fails for the primary ALB"
  alarm_actions = [aws_lambda_function.promote_lambda.arn, aws_sns_topic.alarm_notification_topic.arn]

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }
}