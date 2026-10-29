output "key_arn" {
  description = "ARN of the CMK used for CloudTrail, the trail log group, the delivery topic, and Config objects."
  value       = aws_kms_key.security.arn
}

output "key_id" {
  description = "ID of the CMK used for security service encryption."
  value       = aws_kms_key.security.key_id
}

output "alias_name" {
  description = "Alias name of the security CMK, including the alias/ prefix."
  value       = aws_kms_alias.security.name
}
