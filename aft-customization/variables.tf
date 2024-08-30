variable "environment" {
  description = "the environment for deploy"
  type        = string
  default     = ""
}
variable "lambda_config" {
  type = map(object({
    function_name                 = string
    description                   = string
    handler                       = string
    runtime                       = string
    policy_json                   = string
    local_existing_package        = string
    environment_variables         = map(string)
    create_role                   = bool
    attach_cloudwatch_logs_policy = bool
    create_package                = bool
    attach_policy_json            = bool
    timeout                       = number
  }))
}
variable "iam_role" {
  type = map(object({
    role_name                = string
    create_role              = bool
    trusted_role_arns        = list(string)
    tags                     = map(string)
    inline_policy_statements = list(object({
      actions   = list(string)
      effect    = string
      resources = list(string)
    }))
  }))
}