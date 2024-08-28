output "eventbridge" {
  description = "Event Bridge ID"
  value = aws_cloudwatch_event_rule.imagebuilder.id
}