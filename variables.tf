variable "environment" {
  description = "Short name used in resource names and tags. Lowercase letters, digits, and hyphens only."
  type        = string
  default     = "production"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must contain only lowercase letters, digits, and hyphens."
  }
}

variable "enable_cis_logging" {
  description = "Create the CloudTrail trail, log buckets, CloudWatch log group, delivery alarm, and the CMK those logs use."
  type        = bool
  default     = true
}

variable "enable_cis_alarms" {
  description = "Create CIS Section 4 metric filters and alarms on the CloudTrail log group. Has no effect unless enable_cis_logging is also true."
  type        = bool
  default     = true
}

variable "enable_cis_iam" {
  description = "Create the account password policy, HardenedAdmins group, support role, and IAM Access Analyzer."
  type        = bool
  default     = true
}

variable "enable_cis_networking" {
  description = "Create the IMDSv2 launch template and, when VPC IDs are set, flow logs and default security group cleanup."
  type        = bool
  default     = true
}

variable "enable_cis_encryption" {
  description = "Turn on default EBS encryption in us-east-1 and the additional region."
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable a GuardDuty detector in us-east-1 and the additional region."
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable the AWS Config recorder in us-east-1 and the additional region."
  type        = bool
  default     = true
}

variable "additional_regions" {
  description = "Exactly one region besides us-east-1. Regional guardrails are created in us-east-1 and this region."
  type        = list(string)
  default     = ["us-west-2"]

  validation {
    condition     = length(var.additional_regions) == 1 && var.additional_regions[0] != "us-east-1"
    error_message = "additional_regions must contain exactly one region, and it cannot be us-east-1."
  }
}

variable "account_id" {
  description = "12-digit AWS account ID. Used in names and policies so the stack does not call STS to discover the account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "admin_group_name" {
  description = "IAM group that receives the constrained admin policy and the MFA deny policy. No users are created."
  type        = string
  default     = "HardenedAdmins"

  validation {
    condition     = can(regex("^[\\w+=,.@-]+$", var.admin_group_name))
    error_message = "admin_group_name contains characters IAM group names do not allow."
  }
}

variable "vpc_ids" {
  description = "VPC IDs in us-east-1 that receive flow logs and a default security group with no rules."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.vpc_ids : can(regex("^vpc-[0-9a-f]+$", id))
    ])
    error_message = "vpc_ids must be VPC IDs such as vpc-0123456789abcdef0."
  }
}

variable "additional_region_vpc_ids" {
  description = "VPC IDs in the additional region that receive flow logs and a default security group with no rules."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.additional_region_vpc_ids : can(regex("^vpc-[0-9a-f]+$", id))
    ])
    error_message = "additional_region_vpc_ids must be VPC IDs such as vpc-0123456789abcdef0."
  }
}

variable "discover_vpcs" {
  description = "When true, attach flow logs and lock the default security group on every VPC visible in us-east-1 and the additional region. Default is false so an apply does not edit existing VPCs."
  type        = bool
  default     = false
}
