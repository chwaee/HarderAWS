output "recorder_name" {
  description = "Name of the AWS Config recorder in this region."
  value       = aws_config_configuration_recorder.this.name
}

output "bucket_name" {
  description = "Delivery bucket name. The home-region instance creates it. The other region reuses it."
  value       = local.bucket_name
}

output "role_arn" {
  description = "ARN of the AWS Config service-linked role."
  value       = local.role_arn
}
