locals {
  home_region       = "us-east-1"
  name_prefix       = "harderaws-${var.environment}"
  trail_name        = "${local.name_prefix}-management"
  log_group_name    = "/harderaws/${var.environment}/cloudtrail"
  trail_arn         = "arn:aws:cloudtrail:${local.home_region}:${var.account_id}:trail/${local.trail_name}"
  log_group_arn     = "arn:aws:logs:${local.home_region}:${var.account_id}:log-group:${local.log_group_name}"
  config_source_arn = "arn:aws:config:%s:${var.account_id}:*"
}

# CIS: 3.5, 3.6
# Key policies require Resource "*". The account root statement delegates administration to IAM.
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_kms_key" "security" {
  description             = "Encrypts CloudTrail, the trail log group, the delivery topic, and Config snapshots."
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
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DeleteAlias",
          "kms:DescribeKey",
          "kms:DisableKey",
          "kms:DisableKeyRotation",
          "kms:EnableKey",
          "kms:EnableKeyRotation",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:ListAliases",
          "kms:ListGrants",
          "kms:ListKeyPolicies",
          "kms:ListResourceTags",
          "kms:PutKeyPolicy",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
          "kms:RetireGrant",
          "kms:RevokeGrant",
          "kms:ScheduleKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:UpdateAlias",
          "kms:UpdateKeyDescription",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrailEncrypt"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceArn"                            = local.trail_arn
            "kms:EncryptionContext:aws:cloudtrail:arn" = local.trail_arn
          }
        }
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.home_region}.amazonaws.com"
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
      {
        Sid    = "AllowAlarmPublish"
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "sns.amazonaws.com",
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
        }
      },
      {
        Sid    = "AllowConfigDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = var.account_id
          }
          ArnLike = {
            "AWS:SourceArn" = [
              format(local.config_source_arn, local.home_region),
              format(local.config_source_arn, var.additional_region),
            ]
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "security" {
  name          = "alias/${local.name_prefix}-security"
  target_key_id = aws_kms_key.security.key_id
}
