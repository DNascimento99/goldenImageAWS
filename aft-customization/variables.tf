variable "lambda_config" {
  type = map(object({
    function_name = string
    description   = string
    handler       = string
    runtime       = string
  }))
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "create_role" {
  type = map(object({
    role_name          = string
    description        = string
    path               = string
    policy_name        = string
    policy             = string
    assume_role_policy = string
  }))
}
