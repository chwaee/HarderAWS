output "alarm_name_cis_4_1" {
  description = "Name of the CIS 4.1 unauthorized API calls alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.unauthorized_api_calls[*].alarm_name)
}

output "alarm_arn_cis_4_1" {
  description = "ARN of the CIS 4.1 unauthorized API calls alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.unauthorized_api_calls[*].arn)
}

output "alarm_name_cis_4_2" {
  description = "Name of the CIS 4.2 console sign-in without MFA alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.console_signin_without_mfa[*].alarm_name)
}

output "alarm_arn_cis_4_2" {
  description = "ARN of the CIS 4.2 console sign-in without MFA alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.console_signin_without_mfa[*].arn)
}

output "alarm_name_cis_4_3" {
  description = "Name of the CIS 4.3 root account use alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.root_account_use[*].alarm_name)
}

output "alarm_arn_cis_4_3" {
  description = "ARN of the CIS 4.3 root account use alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.root_account_use[*].arn)
}

output "alarm_name_cis_4_4" {
  description = "Name of the CIS 4.4 IAM policy changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.iam_policy_changes[*].alarm_name)
}

output "alarm_arn_cis_4_4" {
  description = "ARN of the CIS 4.4 IAM policy changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.iam_policy_changes[*].arn)
}

output "alarm_name_cis_4_5" {
  description = "Name of the CIS 4.5 CloudTrail configuration changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.cloudtrail_configuration_changes[*].alarm_name)
}

output "alarm_arn_cis_4_5" {
  description = "ARN of the CIS 4.5 CloudTrail configuration changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.cloudtrail_configuration_changes[*].arn)
}

output "alarm_name_cis_4_6" {
  description = "Name of the CIS 4.6 console authentication failures alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.console_authentication_failures[*].alarm_name)
}

output "alarm_arn_cis_4_6" {
  description = "ARN of the CIS 4.6 console authentication failures alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.console_authentication_failures[*].arn)
}

output "alarm_name_cis_4_7" {
  description = "Name of the CIS 4.7 CMK disable or scheduled deletion alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.cmk_disable_or_deletion[*].alarm_name)
}

output "alarm_arn_cis_4_7" {
  description = "ARN of the CIS 4.7 CMK disable or scheduled deletion alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.cmk_disable_or_deletion[*].arn)
}

output "alarm_name_cis_4_8" {
  description = "Name of the CIS 4.8 S3 bucket policy changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.s3_bucket_policy_changes[*].alarm_name)
}

output "alarm_arn_cis_4_8" {
  description = "ARN of the CIS 4.8 S3 bucket policy changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.s3_bucket_policy_changes[*].arn)
}

output "alarm_name_cis_4_9" {
  description = "Name of the CIS 4.9 AWS Config changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.config_changes[*].alarm_name)
}

output "alarm_arn_cis_4_9" {
  description = "ARN of the CIS 4.9 AWS Config changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.config_changes[*].arn)
}

output "alarm_name_cis_4_10" {
  description = "Name of the CIS 4.10 security group changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.security_group_changes[*].alarm_name)
}

output "alarm_arn_cis_4_10" {
  description = "ARN of the CIS 4.10 security group changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.security_group_changes[*].arn)
}

output "alarm_name_cis_4_11" {
  description = "Name of the CIS 4.11 NACL changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.nacl_changes[*].alarm_name)
}

output "alarm_arn_cis_4_11" {
  description = "ARN of the CIS 4.11 NACL changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.nacl_changes[*].arn)
}

output "alarm_name_cis_4_12" {
  description = "Name of the CIS 4.12 network gateway changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.network_gateway_changes[*].alarm_name)
}

output "alarm_arn_cis_4_12" {
  description = "ARN of the CIS 4.12 network gateway changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.network_gateway_changes[*].arn)
}

output "alarm_name_cis_4_13" {
  description = "Name of the CIS 4.13 route table changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.route_table_changes[*].alarm_name)
}

output "alarm_arn_cis_4_13" {
  description = "ARN of the CIS 4.13 route table changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.route_table_changes[*].arn)
}

output "alarm_name_cis_4_14" {
  description = "Name of the CIS 4.14 VPC changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.vpc_changes[*].alarm_name)
}

output "alarm_arn_cis_4_14" {
  description = "ARN of the CIS 4.14 VPC changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.vpc_changes[*].arn)
}

output "alarm_name_cis_4_15" {
  description = "Name of the CIS 4.15 AWS Organizations changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.organizations_changes[*].alarm_name)
}

output "alarm_arn_cis_4_15" {
  description = "ARN of the CIS 4.15 AWS Organizations changes alarm. Null when enable_all is false."
  value       = one(aws_cloudwatch_metric_alarm.organizations_changes[*].arn)
}
