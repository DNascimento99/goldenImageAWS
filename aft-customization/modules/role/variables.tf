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