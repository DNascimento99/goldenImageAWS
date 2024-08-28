resource "aws_cloudwatch_log_group" "imagebuilder" {
  name = "EventBridgeForEventsECS"
  retention_in_days = 1
}