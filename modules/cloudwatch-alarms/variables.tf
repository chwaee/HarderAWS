variable "environment" {
  description = "Name segment used in alarm and metric filter names."
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group that receives CloudTrail events."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic that receives alarm and OK actions."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in metric filter names."
  type        = string
}

variable "enable_all" {
  description = "When false, no metric filters or alarms are created."
  type        = bool
  default     = true
}
