output "iam_role_arn" {
  description = "ARN of IAM role"
  value = { for key, mod in module.role : key => mod.iam_role_arn }
}