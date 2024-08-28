resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "EC2ImageBuilderEventBridgeAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "Invocations"
  namespace                 = "AWS/Events"
  period                    = 10
  statistic                 = "Maximum"
  threshold                 = 0
  alarm_description         = "Alarm triggered by EventBridge ECS ERROR events"
  treat_missing_data = "notBreaching"
  dimensions = {
    name = "RuleName"
    value = var.eventbridge
  }
}