data "aws_region" "current" {}

data "aws_vpcs" "discovered" {
  count = var.discover_vpcs ? 1 : 0
}

locals {
  vpc_ids        = toset(concat(var.vpc_ids, flatten(data.aws_vpcs.discovered[*].ids)))
  manage_flow    = length(local.vpc_ids) > 0
  log_group_name = "/harderaws/${var.environment}/vpc-flow"
  flow_role_name = "harderaws-${var.environment}-flow-${data.aws_region.current.name}"
  flow_role_arn  = "arn:aws:iam::${var.account_id}:role/${local.flow_role_name}"
  log_group_arn  = "arn:aws:logs:${data.aws_region.current.name}:${var.account_id}:log-group:${local.log_group_name}"
}

# CIS: 1.18
resource "aws_iam_role" "ec2" {
  count = var.create_instance_profile ? 1 : 0
  name  = "harderaws-${var.environment}-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Ec2Assume"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# CIS: 1.18
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_instance_profile ? 1 : 0
  name  = "harderaws-${var.environment}-ec2"
  role  = aws_iam_role.ec2[0].name
}

# CIS: 5.6
resource "aws_launch_template" "imdsv2" {
  name                   = "harderaws-${var.environment}-imdsv2"
  description            = "Requires IMDSv2. Does not select an AMI and does not launch an instance."
  update_default_version = true

  iam_instance_profile {
    name = concat(aws_iam_instance_profile.ec2[*].name, [var.instance_profile_name])[0]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

# CIS: 3.7
# Created only when at least one VPC is in scope. A us-east-1 key cannot encrypt a log group in another region.
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_kms_key" "flow" {
  count                   = local.manage_flow ? 1 : 0
  description             = "Encrypts VPC flow logs in ${data.aws_region.current.name}."
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIamAdministration"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = [
          "kms:CancelKeyDeletion",
          "kms:CreateAlias",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:EnableKey",
          "kms:EnableKeyRotation",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowFlowLogWriter"
        Effect = "Allow"
        Principal = {
          AWS = local.flow_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = local.log_group_arn
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "flow" {
  count         = local.manage_flow ? 1 : 0
  name          = "alias/harderaws-${var.environment}-flow-${data.aws_region.current.name}"
  target_key_id = aws_kms_key.flow[0].key_id
}

# CIS: 3.7
resource "aws_cloudwatch_log_group" "flow" {
  count             = local.manage_flow ? 1 : 0
  name              = local.log_group_name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flow[0].arn
}

resource "aws_iam_role" "flow" {
  count = local.manage_flow ? 1 : 0
  name  = local.flow_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VpcFlowLogsAssume"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# Stream names are assigned when logs arrive.
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "flow" {
  count = local.manage_flow ? 1 : 0
  name  = local.flow_role_name
  role  = aws_iam_role.flow[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteFlowLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.flow[0].arn}:*"
      },
    ]
  })
}

# CIS: 3.7
resource "aws_flow_log" "this" {
  for_each                 = local.vpc_ids
  vpc_id                   = each.value
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow[0].arn
  iam_role_arn             = aws_iam_role.flow[0].arn
  max_aggregation_interval = 60
}

# CIS: 5.4
resource "aws_default_security_group" "this" {
  for_each = local.vpc_ids
  vpc_id   = each.value

  ingress = []
  egress  = []
}
