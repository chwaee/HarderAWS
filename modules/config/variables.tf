variable "environment" {
  description = "Name segment used in the recorder and bucket names."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in the bucket policy."
  type        = string
}

variable "kms_key_arn" {
  description = "CMK ARN in the same region as the Config bucket. Both recorders deliver to that bucket."
  type        = string
}

variable "create_bucket" {
  description = "Create the delivery bucket. True in us-east-1 only."
  type        = bool
}

variable "config_bucket_name" {
  description = "Existing delivery bucket name. Required when create_bucket is false."
  type        = string
  default     = null
}

variable "access_log_bucket_name" {
  description = "Bucket that receives S3 server access logs. When null and create_bucket is true, this module creates one."
  type        = string
  default     = null
}

variable "create_service_linked_role" {
  description = "Create the Config service-linked role. True in one region only."
  type        = bool
}

variable "config_role_arn" {
  description = "Existing Config service-linked role ARN. Required when create_service_linked_role is false."
  type        = string
  default     = null
}

variable "include_global_resource_types" {
  description = "Record global resource types. True in one region only."
  type        = bool
}

variable "delivery_prefix" {
  description = "S3 key prefix for this region's Config snapshots."
  type        = string
}

variable "config_source_regions" {
  description = "Regions allowed to deliver Config snapshots into the bucket. Used only when create_bucket is true."
  type        = list(string)
  default     = []
}
