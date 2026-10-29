output "account_public_access_block_id" {
  description = "Account ID of the S3 Block Public Access setting."
  value       = aws_s3_account_public_access_block.this.id
}
