resource "aws_cloudwatch_event_rule" "imagebuilder" {
  name        = "EC2ImageBuilderEventBridgeForEventsECS-Dev"
  description = "Ativação de rollback do image builder"

  event_pattern = jsonencode({
    detail-type = [
      "ECS Service Action",
      "ECS Task State Change"
    ]
    detail = {
        clusterArn = ["arn:aws:ecs:us-east-1:952494594903:cluster/ClusterDev"],
        eventTyp = ["ERROR"]
  }
  })
}
resource "aws_cloudwatch_event_target" "loggroup" {
  rule      = aws_cloudwatch_event_rule.imagebuilder.name
  target_id = "SendToLogGroup"
  arn       = var.loggroup
}