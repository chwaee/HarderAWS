variable "environment" {
  description = "Name segment used in policy and role names."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in ARNs."
  type        = string
}

variable "admin_group_name" {
  description = "IAM group that receives the constrained admin policy and the MFA deny policy."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional CMK ARN the admin group may describe and rotate. Null when the key is not created."
  type        = string
  default     = null
}
