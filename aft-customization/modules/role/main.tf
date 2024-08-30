module "role" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  for_each = var.iam_role

  create_role              = each.value.create_role
  role_name                = each.value.role_name
  trusted_role_arns        = each.value.trusted_role_arns
  tags                     = each.value.tags
  inline_policy_statements = each.value.inline_policy_statements
}