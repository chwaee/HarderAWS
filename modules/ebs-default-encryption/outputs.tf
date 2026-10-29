output "enabled" {
  description = "Whether default EBS encryption is enabled in this region."
  value       = aws_ebs_encryption_by_default.this.enabled
}
