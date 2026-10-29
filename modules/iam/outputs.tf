output "admin_group_name" {
  description = "Name of the IAM group that holds the constrained admin policy."
  value       = aws_iam_group.admins.name
}

output "admin_group_arn" {
  description = "ARN of the IAM group that holds the constrained admin policy."
  value       = aws_iam_group.admins.arn
}

output "support_role_arn" {
  description = "ARN of the support role. CIS 1.17."
  value       = aws_iam_role.support.arn
}

output "scp_policy_document" {
  description = "JSON SCP for the organization root. This module does not attach it."
  value       = local.scp_policy_document
}
