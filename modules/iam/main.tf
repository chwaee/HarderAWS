locals {
  name_prefix = "harderaws-${var.environment}"
  trail_arn   = "arn:aws:cloudtrail:us-east-1:${var.account_id}:trail/${local.name_prefix}-management"
  support_arn = "arn:aws:iam::${var.account_id}:role/${local.name_prefix}-support"

  kms_statements = [
    for arn in compact([var.kms_key_arn]) : {
      Sid    = "ManageTrailKeyRotation"
      Effect = "Allow"
      Action = [
        "kms:DescribeKey",
        "kms:EnableKeyRotation",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
      ]
      Resource = arn
    }
  ]

  scoped_statements = concat(
    [
      {
        Sid    = "ReadCloudTrail"
        Effect = "Allow"
        Action = [
          "cloudtrail:GetEventSelectors",
          "cloudtrail:GetTrail",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:ListTags",
        ]
        Resource = local.trail_arn
      },
      {
        Sid      = "AssumeSupportRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = local.support_arn
      },
    ],
    local.kms_statements,
  )

  # Account-level APIs reject a specific resource ARN. Actions stay explicit.
  account_statements = [
    {
      Sid    = "OperateAccountGuardrails"
      Effect = "Allow"
      Action = [
        "access-analyzer:GetAnalyzer",
        "access-analyzer:ListAnalyzers",
        "cloudtrail:DescribeTrails",
        "cloudtrail:LookupEvents",
        "config:DescribeConfigurationRecorderStatus",
        "config:DescribeConfigurationRecorders",
        "config:DescribeDeliveryChannels",
        "config:PutConfigurationRecorder",
        "config:StartConfigurationRecorder",
        "ec2:EnableEbsEncryptionByDefault",
        "ec2:GetEbsDefaultKmsKeyId",
        "ec2:GetEbsEncryptionByDefault",
        "guardduty:GetDetector",
        "guardduty:ListDetectors",
        "iam:ChangePassword",
        "iam:CreateVirtualMFADevice",
        "iam:DeactivateMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetAccountPasswordPolicy",
        "iam:GetAccountSummary",
        "iam:GetUser",
        "iam:ListGroups",
        "iam:ListMFADevices",
        "iam:ListPolicies",
        "iam:ListRoles",
        "iam:ListUsers",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "iam:UpdateAccountPasswordPolicy",
        "logs:DescribeLogGroups",
        "s3:GetAccountPublicAccessBlock",
        "s3:ListAllMyBuckets",
        "s3:PutAccountPublicAccessBlock",
        "sns:GetTopicAttributes",
        "sns:ListTopics",
        "sts:GetCallerIdentity",
      ]
      Resource = "*"
    }
  ]

  scp_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDisablingSecurityServices"
        Effect = "Deny"
        Action = [
          "access-analyzer:DeleteAnalyzer",
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder",
          "ec2:DisableEbsEncryptionByDefault",
          "guardduty:DeleteDetector",
          "guardduty:UpdateDetector",
          "s3:PutAccountPublicAccessBlock",
        ]
        Resource = "*"
        Condition = {
          ArnNotLike = {
            "aws:PrincipalARN" = "arn:aws:iam::${var.account_id}:role/REPLACE_WITH_BREAK_GLASS_ROLE"
          }
        }
      },
      {
        Sid    = "DenyAttachingFullAdminPolicies"
        Effect = "Deny"
        Action = [
          "iam:AttachGroupPolicy",
          "iam:AttachRolePolicy",
          "iam:AttachUserPolicy",
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "iam:PolicyARN" = [
              "arn:aws:iam::aws:policy/AdministratorAccess",
              "arn:aws:iam::aws:policy/IAMFullAccess",
            ]
          }
        }
      },
      {
        Sid      = "DenyS3WithoutTls"
        Effect   = "Deny"
        Action   = "s3:*"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

# CIS: 1.8, 1.9
# Character classes and a 90-day maximum age are set because the stack asks for them.
# CIS v3.0.0 no longer has separate control IDs for those settings.
# IAM account password policy has no lockout attribute.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
  hard_expiry                    = false
}

# CIS: 1.15
resource "aws_iam_group" "admins" {
  name = var.admin_group_name
}

# CIS: 1.16
resource "aws_iam_policy" "admin_scoped" {
  name        = "${local.name_prefix}-admin-scoped"
  description = "Resource-scoped rights for the hardening stack. This is not AdministratorAccess."
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.scoped_statements
  })
}

# CIS: 1.16
# Account-level IAM, CloudTrail, Config, GuardDuty, and EC2 APIs only accept Resource "*".
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "admin_account" {
  name        = "${local.name_prefix}-admin-account"
  description = "Account-level read and operate rights for the hardening stack. Actions are listed. This is not AdministratorAccess."
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.account_statements
  })
}

# CIS: 1.10
# Deny is account-wide for group members, so Resource "*" is required.
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "require_mfa" {
  name        = "${local.name_prefix}-require-mfa"
  description = "Denies every action except MFA enrollment and password change when the session has no MFA."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyWithoutMfa"
        Effect = "Deny"
        NotAction = [
          "iam:ChangePassword",
          "iam:CreateVirtualMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetAccountPasswordPolicy",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetCallerIdentity",
          "sts:GetSessionToken",
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# CIS: 1.15
resource "aws_iam_group_policy_attachment" "admin_scoped" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.admin_scoped.arn
}

# CIS: 1.15, 1.16
resource "aws_iam_group_policy_attachment" "admin_account" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.admin_account.arn
}

# CIS: 1.10, 1.15
resource "aws_iam_group_policy_attachment" "require_mfa" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

# CIS: 1.17
resource "aws_iam_role" "support" {
  name = "${local.name_prefix}-support"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccountPrincipalsWithMfa"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

# CIS: 1.17
resource "aws_iam_role_policy_attachment" "support" {
  role       = aws_iam_role.support.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
