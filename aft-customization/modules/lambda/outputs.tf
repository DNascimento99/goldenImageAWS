output "lambda_function_arns" {
  value = { for k, v in aws_lambda_function.lambda_function : k => v.arn }
}
