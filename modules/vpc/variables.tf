variable "environment" {
  description = "Name segment used in the launch template, flow log group, and flow log role."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in the flow log key policy."
  type        = string
}

variable "vpc_ids" {
  description = "VPC IDs in this provider region that receive flow logs and a default security group with no rules."
  type        = list(string)
  default     = []
}

variable "discover_vpcs" {
  description = "When true, include every VPC the provider can list in this region."
  type        = bool
  default     = false
}

variable "create_instance_profile" {
  description = "Create the EC2 instance profile. Set true in one region only, because IAM is global."
  type        = bool
}

variable "instance_profile_name" {
  description = "Existing instance profile name. Used when create_instance_profile is false."
  type        = string
  default     = null
}
