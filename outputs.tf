output "cloudtrail_trail_arn" {
  description = "ARN of the multi-region CloudTrail trail. Null when logging is disabled."
  value       = try(module.logging[0].trail_arn, null)
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail log bucket. Null when logging is disabled."
  value       = try(module.logging[0].bucket_arn, null)
}

output "alarm_name_cis_4_1" {
  description = "Name of the CIS 4.1 unauthorized API calls alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_1, null)
}

output "alarm_name_cis_4_2" {
  description = "Name of the CIS 4.2 console sign-in without MFA alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_2, null)
}

output "alarm_name_cis_4_3" {
  description = "Name of the CIS 4.3 root account use alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_3, null)
}

output "alarm_name_cis_4_4" {
  description = "Name of the CIS 4.4 IAM policy changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_4, null)
}

output "alarm_name_cis_4_5" {
  description = "Name of the CIS 4.5 CloudTrail configuration changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_5, null)
}

output "alarm_name_cis_4_6" {
  description = "Name of the CIS 4.6 console authentication failures alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_6, null)
}

output "alarm_name_cis_4_7" {
  description = "Name of the CIS 4.7 CMK disable or scheduled deletion alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_7, null)
}

output "alarm_name_cis_4_8" {
  description = "Name of the CIS 4.8 S3 bucket policy changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_8, null)
}

output "alarm_name_cis_4_9" {
  description = "Name of the CIS 4.9 AWS Config changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_9, null)
}

output "alarm_name_cis_4_10" {
  description = "Name of the CIS 4.10 security group changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_10, null)
}

output "alarm_name_cis_4_11" {
  description = "Name of the CIS 4.11 NACL changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_11, null)
}

output "alarm_name_cis_4_12" {
  description = "Name of the CIS 4.12 network gateway changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_12, null)
}

output "alarm_name_cis_4_13" {
  description = "Name of the CIS 4.13 route table changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_13, null)
}

output "alarm_name_cis_4_14" {
  description = "Name of the CIS 4.14 VPC changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_14, null)
}

output "alarm_name_cis_4_15" {
  description = "Name of the CIS 4.15 AWS Organizations changes alarm. Null when logging or CIS alarms are disabled."
  value       = try(module.cloudwatch_alarms[0].alarm_name_cis_4_15, null)
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder in us-east-1. Null when Config is disabled."
  value       = try(module.config_home[0].recorder_name, null)
}

output "config_recorder_names" {
  description = "AWS Config recorder names keyed by region."
  value = {
    for region, name in {
      "us-east-1"                 = try(module.config_home[0].recorder_name, null)
      (var.additional_regions[0]) = try(module.config_additional[0].recorder_name, null)
    } : region => name if name != null
  }
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID in us-east-1. Null when GuardDuty is disabled."
  value       = try(module.guardduty_home[0].detector_id, null)
}

output "guardduty_detector_ids" {
  description = "GuardDuty detector IDs keyed by region."
  value = {
    for region, id in {
      "us-east-1"                 = try(module.guardduty_home[0].detector_id, null)
      (var.additional_regions[0]) = try(module.guardduty_additional[0].detector_id, null)
    } : region => id if id != null
  }
}

output "kms_key_arn" {
  description = "ARN of the CMK used for CloudTrail and Config. Null when logging and Config are both disabled."
  value       = try(module.kms[0].key_arn, null)
}

output "flow_log_ids" {
  description = "IDs of VPC flow logs created for opted-in VPCs."
  value = concat(
    try(module.vpc_home[0].flow_log_ids, []),
    try(module.vpc_additional[0].flow_log_ids, []),
  )
}

output "access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer in us-east-1. Null when IAM controls are disabled."
  value       = try(module.access_analyzer_home[0].analyzer_arn, null)
}

output "access_analyzer_arns" {
  description = "IAM Access Analyzer ARNs keyed by region."
  value = {
    for region, arn in {
      "us-east-1"                 = try(module.access_analyzer_home[0].analyzer_arn, null)
      (var.additional_regions[0]) = try(module.access_analyzer_additional[0].analyzer_arn, null)
    } : region => arn if arn != null
  }
}

output "admin_group_name" {
  description = "Name of the constrained admin group. Null when IAM controls are disabled."
  value       = try(module.iam[0].admin_group_name, null)
}

output "scp_policy_document" {
  description = "JSON SCP for an organization administrator to attach. This stack does not attach it."
  value       = try(module.iam[0].scp_policy_document, null)
}

output "imdsv2_launch_template_id" {
  description = "ID of the us-east-1 launch template that requires IMDSv2. Null when networking controls are disabled."
  value       = try(module.vpc_home[0].launch_template_id, null)
}

output "imdsv2_launch_template_ids" {
  description = "IMDSv2 launch template IDs keyed by region."
  value = {
    for region, id in {
      "us-east-1"                 = try(module.vpc_home[0].launch_template_id, null)
      (var.additional_regions[0]) = try(module.vpc_additional[0].launch_template_id, null)
    } : region => id if id != null
  }
}
