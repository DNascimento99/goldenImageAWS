output "loggroup" {
  description = "Log Group ID"
  value = aws_cloudwatch_log_group.imagebuilder
}