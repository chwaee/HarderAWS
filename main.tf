module "iam" {
  count  = var.enable_cis_iam ? 1 : 0
  source = "./modules/iam"

  environment      = var.environment
  account_id       = var.account_id
  admin_group_name = var.admin_group_name
  kms_key_arn      = try(module.kms[0].key_arn, null)
}

module "kms" {
  count  = var.enable_cis_logging || var.enable_config ? 1 : 0
  source = "./modules/kms"

  environment       = var.environment
  account_id        = var.account_id
  additional_region = var.additional_regions[0]
}

module "logging" {
  count  = var.enable_cis_logging ? 1 : 0
  source = "./modules/logging"

  environment = var.environment
  account_id  = var.account_id
  kms_key_arn = try(module.kms[0].key_arn, null)
}

module "cloudwatch_alarms" {
  count  = var.enable_cis_logging && var.enable_cis_alarms ? 1 : 0
  source = "./modules/cloudwatch-alarms"

  environment    = var.environment
  account_id     = var.account_id
  log_group_name = try(module.logging[0].log_group_name, null)
  sns_topic_arn  = try(module.logging[0].sns_topic_arn, null)
}

module "s3_guardrails" {
  source = "./modules/s3-guardrails"
}

module "vpc_home" {
  count  = var.enable_cis_networking ? 1 : 0
  source = "./modules/vpc"

  environment             = var.environment
  account_id              = var.account_id
  vpc_ids                 = var.vpc_ids
  discover_vpcs           = var.discover_vpcs
  create_instance_profile = true
}

module "vpc_additional" {
  count  = var.enable_cis_networking ? 1 : 0
  source = "./modules/vpc"

  providers = {
    aws = aws.additional
  }

  environment             = var.environment
  account_id              = var.account_id
  vpc_ids                 = var.additional_region_vpc_ids
  discover_vpcs           = var.discover_vpcs
  create_instance_profile = false
  instance_profile_name   = try(module.vpc_home[0].instance_profile_name, null)
}

module "config_home" {
  count  = var.enable_config ? 1 : 0
  source = "./modules/config"

  environment                   = var.environment
  account_id                    = var.account_id
  kms_key_arn                   = try(module.kms[0].key_arn, null)
  create_bucket                 = true
  access_log_bucket_name        = try(module.logging[0].access_log_bucket_name, null)
  create_service_linked_role    = true
  include_global_resource_types = true
  delivery_prefix               = "config/us-east-1"
  config_source_regions         = ["us-east-1", var.additional_regions[0]]
}

module "config_additional" {
  count  = var.enable_config ? 1 : 0
  source = "./modules/config"

  providers = {
    aws = aws.additional
  }

  environment                   = var.environment
  account_id                    = var.account_id
  kms_key_arn                   = try(module.kms[0].key_arn, null)
  create_bucket                 = false
  config_bucket_name            = try(module.config_home[0].bucket_name, null)
  create_service_linked_role    = false
  config_role_arn               = try(module.config_home[0].role_arn, null)
  include_global_resource_types = false
  delivery_prefix               = "config/${var.additional_regions[0]}"
}

module "guardduty_home" {
  count  = var.enable_guardduty ? 1 : 0
  source = "./modules/guardduty"
}

module "guardduty_additional" {
  count  = var.enable_guardduty ? 1 : 0
  source = "./modules/guardduty"

  providers = {
    aws = aws.additional
  }
}

module "access_analyzer_home" {
  count  = var.enable_cis_iam ? 1 : 0
  source = "./modules/access-analyzer"

  environment = var.environment
}

module "access_analyzer_additional" {
  count  = var.enable_cis_iam ? 1 : 0
  source = "./modules/access-analyzer"

  providers = {
    aws = aws.additional
  }

  environment = var.environment
}

module "ebs_home" {
  count  = var.enable_cis_encryption ? 1 : 0
  source = "./modules/ebs-default-encryption"
}

module "ebs_additional" {
  count  = var.enable_cis_encryption ? 1 : 0
  source = "./modules/ebs-default-encryption"

  providers = {
    aws = aws.additional
  }
}
