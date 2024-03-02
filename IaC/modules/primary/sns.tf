resource "aws_sns_topic" "alarm_notification_topic" {
  name = "AlarmNotificationTopic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_notification_topic.arn
  protocol  = "email"
  endpoint  = "adri.gp7@gmail.com"
}

resource "aws_sns_topic_subscription" "javier_email_subscription" {
  topic_arn = aws_sns_topic.alarm_notification_topic.arn
  protocol  = "email"
  endpoint  = "email@javier-moreno.com"
}

resource "aws_sns_topic_subscription" "rene_email_subscription" {
  topic_arn = aws_sns_topic.alarm_notification_topic.arn
  protocol  = "email"
  endpoint  = "rene.serral@upc.edu"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.alarm_notification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.promote_lambda.arn
}