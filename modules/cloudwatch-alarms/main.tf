locals {
  name_prefix      = "harderaws-${var.environment}"
  metric_namespace = "HarderAWS/CIS"
}

# CIS: 4.1
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.1"
  log_group_name = var.log_group_name
  pattern        = "{ $.errorCode = \"AccessDenied\" }"

  metric_transformation {
    name      = "UnauthorizedApiCalls"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.1"
  alarm_description   = "CIS 4.1 Unauthorized API calls (AccessDenied). This filter is noisy."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.2
resource "aws_cloudwatch_log_metric_filter" "console_signin_without_mfa" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.2"
  log_group_name = var.log_group_name
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.errorMessage = \"AWS Security Credentials are not provided.\") }"

  metric_transformation {
    name      = "ConsoleSignInWithoutMfa"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_without_mfa" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.2"
  alarm_description   = "CIS 4.2 Console sign-in without MFA."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.console_signin_without_mfa[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.console_signin_without_mfa[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.3
resource "aws_cloudwatch_log_metric_filter" "root_account_use" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.3"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"Root\") && ($.eventName = \"ConsoleLogin\") && ($.responseElements.ConsoleLogin = \"Success\") }"

  metric_transformation {
    name      = "RootAccountUse"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_use" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.3"
  alarm_description   = "CIS 4.3 Root account console sign-in."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_account_use[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_account_use[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.4
resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.4"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"DeleteGroupPolicy\" || $.eventName = \"DeleteRolePolicy\" || $.eventName = \"DeleteUserPolicy\" || $.eventName = \"PutGroupPolicy\" || $.eventName = \"PutRolePolicy\" || $.eventName = \"PutUserPolicy\" || $.eventName = \"AttachGroupPolicy\" || $.eventName = \"AttachRolePolicy\" || $.eventName = \"AttachUserPolicy\" || $.eventName = \"CreatePolicy\" || $.eventName = \"DeletePolicy\" || $.eventName = \"CreatePolicyVersion\" || $.eventName = \"DeletePolicyVersion\" || $.eventName = \"DetachGroupPolicy\" || $.eventName = \"DetachRolePolicy\" || $.eventName = \"DetachUserPolicy\") }"

  metric_transformation {
    name      = "IamPolicyChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_policy_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.4"
  alarm_description   = "CIS 4.4 IAM policy changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.iam_policy_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.iam_policy_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.5
resource "aws_cloudwatch_log_metric_filter" "cloudtrail_configuration_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.5"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"StopLogging\" || $.eventName = \"DeleteTrail\" || $.eventName = \"UpdateTrail\") }"

  metric_transformation {
    name      = "CloudTrailConfigurationChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_configuration_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.5"
  alarm_description   = "CIS 4.5 CloudTrail configuration changes by an IAM user. Missing metric data is breaching."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.cloudtrail_configuration_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.cloudtrail_configuration_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "breaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.6
resource "aws_cloudwatch_log_metric_filter" "console_authentication_failures" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.6"
  log_group_name = var.log_group_name
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.errorMessage = \"Failed authentication\" || $.errorCode = \"FailedAuthentication\") }"

  metric_transformation {
    name      = "ConsoleAuthenticationFailures"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_authentication_failures" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.6"
  alarm_description   = "CIS 4.6 Console authentication failures."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.console_authentication_failures[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.console_authentication_failures[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.7
resource "aws_cloudwatch_log_metric_filter" "cmk_disable_or_deletion" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.7"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"ScheduleKeyDeletion\" || $.eventName = \"DisableKey\") }"

  metric_transformation {
    name      = "CmkDisableOrScheduledDeletion"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cmk_disable_or_deletion" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.7"
  alarm_description   = "CIS 4.7 CMK disable or scheduled deletion by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.cmk_disable_or_deletion[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.cmk_disable_or_deletion[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.8
resource "aws_cloudwatch_log_metric_filter" "s3_bucket_policy_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.8"
  log_group_name = var.log_group_name
  pattern        = "{ ($.requestParameters.bucketName = \"*\") && ($.eventName = \"PutBucketPolicy\" || $.eventName = \"DeleteBucketPolicy\" || $.eventName = \"PutBucketAcl\") }"

  metric_transformation {
    name      = "S3BucketPolicyChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_policy_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.8"
  alarm_description   = "CIS 4.8 S3 bucket policy or ACL changes."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.s3_bucket_policy_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.s3_bucket_policy_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.9
resource "aws_cloudwatch_log_metric_filter" "config_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.9"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"StopConfigurationRecorder\" || $.eventName = \"DeleteConfigurationRecorder\" || $.eventName = \"DeleteDeliveryChannel\" || $.eventName = \"PutConfigurationRecorder\" || $.eventName = \"PutDeliveryChannel\") }"

  metric_transformation {
    name      = "AwsConfigChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "config_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.9"
  alarm_description   = "CIS 4.9 AWS Config recorder or delivery channel changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.config_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.config_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.10
resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.10"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"AuthorizeSecurityGroupIngress\" || $.eventName = \"AuthorizeSecurityGroupEgress\" || $.eventName = \"RevokeSecurityGroupIngress\" || $.eventName = \"RevokeSecurityGroupEgress\" || $.eventName = \"CreateSecurityGroup\" || $.eventName = \"DeleteSecurityGroup\") }"

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.10"
  alarm_description   = "CIS 4.10 Security group changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.security_group_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.security_group_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.11
resource "aws_cloudwatch_log_metric_filter" "nacl_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.11"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"CreateNetworkAcl\" || $.eventName = \"CreateNetworkAclEntry\" || $.eventName = \"DeleteNetworkAcl\" || $.eventName = \"DeleteNetworkAclEntry\" || $.eventName = \"ReplaceNetworkAclEntry\" || $.eventName = \"ReplaceNetworkAclAssociation\") }"

  metric_transformation {
    name      = "NaclChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.11"
  alarm_description   = "CIS 4.11 Network ACL changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.nacl_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.nacl_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.12
resource "aws_cloudwatch_log_metric_filter" "network_gateway_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.12"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"CreateCustomerGateway\" || $.eventName = \"CreateInternetGateway\" || $.eventName = \"CreateVpnGateway\" || $.eventName = \"AttachInternetGateway\" || $.eventName = \"AttachVpnGateway\" || $.eventName = \"DeleteCustomerGateway\" || $.eventName = \"DeleteInternetGateway\" || $.eventName = \"DeleteVpnGateway\" || $.eventName = \"DetachInternetGateway\" || $.eventName = \"DetachVpnGateway\") }"

  metric_transformation {
    name      = "NetworkGatewayChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "network_gateway_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.12"
  alarm_description   = "CIS 4.12 Network gateway changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.network_gateway_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.network_gateway_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.13
resource "aws_cloudwatch_log_metric_filter" "route_table_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.13"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"CreateRoute\" || $.eventName = \"CreateRouteTable\" || $.eventName = \"DeleteRoute\" || $.eventName = \"DeleteRouteTable\" || $.eventName = \"ReplaceRoute\" || $.eventName = \"ReplaceRouteTableAssociation\") }"

  metric_transformation {
    name      = "RouteTableChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "route_table_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.13"
  alarm_description   = "CIS 4.13 Route table changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.route_table_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.route_table_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.14
resource "aws_cloudwatch_log_metric_filter" "vpc_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.14"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"CreateVpc\" || $.eventName = \"DeleteVpc\") }"

  metric_transformation {
    name      = "VpcChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.14"
  alarm_description   = "CIS 4.14 VPC changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.vpc_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.vpc_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}

# CIS: 4.15
resource "aws_cloudwatch_log_metric_filter" "organizations_changes" {
  count = var.enable_all ? 1 : 0

  name           = "${local.name_prefix}-${var.account_id}-cis-4.15"
  log_group_name = var.log_group_name
  pattern        = "{ ($.userIdentity.type = \"IAMUser\") && ($.eventName = \"DeleteOrganization\" || $.eventName = \"LeaveOrganization\" || $.eventName = \"DisablePolicyType\" || $.eventName = \"DetachPolicy\" || $.eventName = \"DeletePolicy\" || $.eventName = \"AttachPolicy\" || $.eventName = \"CreatePolicy\" || $.eventName = \"UpdatePolicy\" || $.eventName = \"EnablePolicyType\") }"

  metric_transformation {
    name      = "OrganizationsChanges"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "organizations_changes" {
  count = var.enable_all ? 1 : 0

  alarm_name          = "${local.name_prefix}-cis-4.15"
  alarm_description   = "CIS 4.15 AWS Organizations changes by an IAM user."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.organizations_changes[count.index].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.organizations_changes[count.index].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
}
