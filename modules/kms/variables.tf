variable "environment" {
  description = "Name segment used in the key alias and in the resource names the key policy allows."
  type        = string
}

variable "account_id" {
  description = "12-digit AWS account ID used in key policy conditions."
  type        = string
}

variable "additional_region" {
  description = "Second region whose AWS Config delivery channel may use this key. The key itself stays in us-east-1, next to the Config bucket."
  type        = string
}
