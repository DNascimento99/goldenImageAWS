environment = "dev"
function_name = "LambdaForUpdateLaunchTemplate-And-InstanceRefresh-${environment}"
description = "Lambda for instance refresh in autoscaling"
handler = "index.lambda_handler"
runtime = "Python3.8"

environment_variables = {
  "AutoScalingGroupName" = "TemplateDev"
  "LaunchTemplateName" = "ASGDev"
  "ClusterName" = "ClusterDev"
  "ImagePrefixName" = "Ec2ImageBuilderAMI$-${environment}"
  "RegionName" = "us-east-1"
  "InfraAccountID" = "211125387848"
}
role_name     = "RoleForlambdaUpdateLaunchTemplate-And-InstanceRefresh-${environment}"
description   = "Role using in Lambda for instance refresh in autoscaling"
path          = "service-role"
policy_name   = "Allow"
policy        = string