module "lambda_function" {
  source   = "terraform-aws-modules/lambda/aws"
  for_each = var.lambda_config

  function_name                 = "${each.value.function_name}-${var.environment}"
  description                   = each.value.description
  handler                       = each.value.handler
  runtime                       = each.value.runtime
  environment_variables         = each.value.environment_variables
  create_role                   = each.value.create_role
  attach_cloudwatch_logs_policy = each.value.attach_cloudwatch_logs_policy
  policy_json                   = each.value.policy_json
  create_package                = each.value.create_package
  local_existing_package        = each.value.local_existing_package
  attach_policy_json            = each.value.attach_policy_json
  timeout                       = each.value.timeout
}