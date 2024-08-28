variable "lambda_config" {
    type = map(object({
      function_name     = string
      description       = string
      handler           = string
      runtime           = string
      }))
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "the environment for deploy"
  type = string
  default = ""
}
variable "create_role" {
  type = map(object({
    role_name     = string
    description   = string
    path          = string
    policy_name   = string
    policy        = string
  }))
}