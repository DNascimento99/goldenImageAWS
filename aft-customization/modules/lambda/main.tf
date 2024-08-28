module "lambda_function" {
  source   = "terraform-aws-modules/lambda/aws"
  for_each = var.lambda_config

  function_name          = each.value.function_name
  description            = each.value.description
  handler                = each.value.handler
  runtime                = each.value.runtime
  role_name = aws_iam_role.lambda_role[each.key].name
  environment_variables  = length(keys(var.environment_variables))
  create_package         = false
  local_existing_package = "${path.module}/existing_package.zip"
}
resource "aws_iam_role" "lambda_role" {
  for_each           = var.create_role
  name               = each.value.role_name
  description        = each.value.description
  path               = each.value.path
  assume_role_policy = each.value.assume_role_policy
}

resource "aws_iam_role_policy" "lambda_policy" {
  for_each = var.create_role

  name   = each.value.policy_name
  role   = aws_iam_role.lambda_role[each.key].id
  policy = each.value.policy
}