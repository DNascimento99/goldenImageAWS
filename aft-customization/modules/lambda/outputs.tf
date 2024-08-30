output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = { for key, mod in module.lambda_function : key => mod.lambda_function_arn }
}