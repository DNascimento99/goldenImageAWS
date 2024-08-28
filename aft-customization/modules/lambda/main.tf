module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  for_each = var.lambda_config

  function_name          = each.value.function_name
  description            = each.value.description
  handler                = each.value.handler
  runtime                = each.value.runtime
  environment_variables = length(keys(var.environment_variables)) == 0 ? null : var.environment_variables     
  create_role            = true
  role_name              = each.value.role_name
  attach_cloudwatch_logs_policy = true
  attach_dead_letter_policy = true
  create_package         = false
  local_existing_package = "${path.module}/existing_package.zip"
  
  tags = var.tags
}
