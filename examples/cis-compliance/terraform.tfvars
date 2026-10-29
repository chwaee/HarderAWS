account_id = "123456789012"

environment        = "production"
admin_group_name   = "HardenedAdmins"
additional_regions = ["us-west-2"]

enable_cis_logging    = true
enable_cis_iam        = true
enable_cis_networking = true
enable_cis_encryption = true
enable_guardduty      = true
enable_config         = true

# Flow logs (CIS 3.7) and default security group cleanup (CIS 5.4) start
# when these lists are filled, or when discover_vpcs is true.
vpc_ids                   = []
additional_region_vpc_ids = []
discover_vpcs             = false
