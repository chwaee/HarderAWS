# vpc

Launch template that requires IMDSv2, an instance profile with no admin rights, and opt-in VPC flow logs plus default security group cleanup.

CIS AWS Foundations Benchmark v3.0.0 controls 1.18, 3.7, 5.4, and 5.6. Flow logs and security group changes apply only to `vpc_ids`, or to every VPC in the region when `discover_vpcs` is true.
