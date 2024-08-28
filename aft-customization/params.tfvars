lambda_config = {
  "lambda_instanceRefresh" = {
    function_name = "LambdaForUpdateLaunchTemplate-And-InstanceRefresh-dev"
    description   = "Lambda for instance refresh in autoscaling"
    handler       = "index.lambda_handler"
    runtime       = "Python3.8"
    environment_variables = {
      AutoScalingGroupName = "TemplateDev"
      LaunchTemplateName   = "ASGDev"
      ClusterName          = "ClusterDev"
      ImagePrefixName      = "Ec2ImageBuilderAMI$-dev"
      RegionName           = "us-east-1"
      InfraAccountID       = "211125387848"
}}
}

create_role = {
  "role_lambda_instanceRefresh" = {
    role_name   = "RoleForlambdaUpdateLaunchTemplate-And-InstanceRefresh-dev"
    description = "Role used in Lambda for instance refresh in autoscaling"
    path        = "service-role"
    policy_name = "Allow"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
            "kms:Decrypt",
            "secretsmanager:GetSecretValue"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }]
    })
  }
}
