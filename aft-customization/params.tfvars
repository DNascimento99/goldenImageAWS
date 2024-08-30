environment = "dev"
lambda_config = {
  "lambda_instanceRefresh" = {
    function_name                 = "LambdaForUpdateLaunchTemplate-And-InstanceRefresh"
    description                   = "Lambda for instance refresh in autoscaling"
    handler                       = "index.lambda_handler"
    runtime                       = "python3.12"
    timeout                       = 120
    create_role                   = true
    attach_cloudwatch_logs_policy = true
    create_package                = false
    attach_policy_json            = true
    local_existing_package        = "./instanceRefresh.zip"
    environment_variables = {
      AutoScalingGroupName = "TemplateDev"
      LaunchTemplateName   = "ASGDev"
      ClusterName          = "ClusterDev"
      ImagePrefixName      = "Ec2ImageBuilderAMI-dev"
      RegionName           = "us-east-1"
      InfraAccountID       = "211125387848"
    }
    policy_json = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:TagResource"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:StartInstanceRefresh",
                "autoscaling:Describe*",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:CancelInstanceRefresh",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:DescribeLaunchTemplates",
                "ec2:RunInstances",
                "s3:ListBucket",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:StartInstanceRefresh",
                "autoscaling:RollbackInstanceRefresh",
                "autoscaling:CancelInstanceRefresh"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/managed-by-me": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "RunInstances"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "ec2.amazonaws.com"
                }
            }
        }
    ]
}
EOF
  }
}

iam_role = {
  "role_invoke_lambda" = {
    role_name         = "RoleToInvoke-UpdateLaunchTemplateInstanceRefresh"
    trusted_role_arns = ["arn:aws:iam::211125387848:root"]
    create_role       = true
    tags = {
      environment = "dev"
    }
    inline_policy_statements = [{
      actions = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      effect    = "Allow"
      resources = ["arn:aws:lambda:*:*:function:*"]
    }]
  }
}