variable "environment" {
  description = "Name segment used in the trail, buckets, log group, and topic."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in bucket names and policies."
  type        = string
}

variable "kms_key_arn" {
  description = "CMK ARN from the kms module. The key must already allow CloudTrail, CloudWatch Logs, and SNS."
  type        = string
}
