output "flow_log_ids" {
  description = "IDs of the VPC flow logs created in this region."
  value       = [for flow in aws_flow_log.this : flow.id]
}

output "launch_template_id" {
  description = "ID of the launch template that requires IMDSv2."
  value       = aws_launch_template.imdsv2.id
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile referenced by the launch template."
  value       = concat(aws_iam_instance_profile.ec2[*].name, [var.instance_profile_name])[0]
}

output "instance_profile_arn" {
  description = "ARN of the EC2 instance profile when this module creates it. Null otherwise."
  value       = try(aws_iam_instance_profile.ec2[0].arn, null)
}
