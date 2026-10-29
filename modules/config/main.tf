locals {
  name_prefix   = "harderaws-${var.environment}"
  bucket_name   = concat(aws_s3_bucket.config[*].id, [var.config_bucket_name])[0]
  role_arn      = concat(aws_iam_service_linked_role.config[*].arn, [var.config_role_arn])[0]
  access_logs   = concat(aws_s3_bucket.access[*].id, [var.access_log_bucket_name])[0]
  create_access = var.create_bucket && var.access_log_bucket_name == null
}

resource "aws_iam_service_linked_role" "config" {
  count            = var.create_service_linked_role ? 1 : 0
  aws_service_name = "config.amazonaws.com"
  description      = "Service-linked role for AWS Config, created by the hardening stack."
}

# CIS: 3.3
resource "aws_s3_bucket" "config" {
  count         = var.create_bucket ? 1 : 0
  bucket        = "${local.name_prefix}-${var.account_id}-config"
  force_destroy = false
}

# Logging this bucket to itself would loop.
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "access" {
  count         = local.create_access ? 1 : 0
  bucket        = "${local.name_prefix}-${var.account_id}-config-access"
  force_destroy = false
}

# CIS: 2.1.4
resource "aws_s3_bucket_public_access_block" "config" {
  count                   = var.create_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.config[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# CIS: 2.1.4
resource "aws_s3_bucket_public_access_block" "access" {
  count                   = local.create_access ? 1 : 0
  bucket                  = aws_s3_bucket.access[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "access" {
  count  = local.create_access ? 1 : 0
  bucket = aws_s3_bucket.access[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "access" {
  count  = local.create_access ? 1 : 0
  bucket = aws_s3_bucket.access[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

# S3 server access log delivery requires SSE-S3 on the destination bucket.
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "access" {
  count  = local.create_access ? 1 : 0
  bucket = aws_s3_bucket.access[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "config" {
  count         = var.create_bucket ? 1 : 0
  bucket        = aws_s3_bucket.config[0].id
  target_bucket = local.access_logs
  target_prefix = "config/"
}

# CIS: 2.1.1
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_s3_bucket_policy" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = var.account_id
          }
          ArnLike = {
            "AWS:SourceArn" = [
              for region in var.config_source_regions : "arn:aws:config:${region}:${var.account_id}:*"
            ]
          }
        }
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = var.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = [
          for region in var.config_source_regions :
          "${aws_s3_bucket.config[0].arn}/config/${region}/AWSLogs/${var.account_id}/Config/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = var.account_id
          }
        }
      },
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.config[0].arn,
          "${aws_s3_bucket.config[0].arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.config]
}

# CIS: 2.1.1
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_s3_bucket_policy" "access" {
  count  = local.create_access ? 1 : 0
  bucket = aws_s3_bucket.access[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ServerAccessLogs"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.access[0].arn}/config/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.config[0].arn
          }
        }
      },
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.access[0].arn,
          "${aws_s3_bucket.access[0].arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.access]
}

# CIS: 3.3
resource "aws_config_configuration_recorder" "this" {
  name     = local.name_prefix
  role_arn = local.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

# CIS: 3.3
resource "aws_config_delivery_channel" "this" {
  name           = local.name_prefix
  s3_bucket_name = local.bucket_name
  s3_key_prefix  = var.delivery_prefix
  s3_kms_key_arn = var.kms_key_arn

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

# CIS: 3.3
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}
