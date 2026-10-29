# CIS compliance example

Every flag is set explicitly. Flow logs and default security group changes stay opt-in.

From the repository root:

```bash
terraform init
terraform plan -var-file=examples/cis-compliance/terraform.tfvars
terraform apply -var-file=examples/cis-compliance/terraform.tfvars
```

Replace `account_id` before you plan against a real account. Add VPC IDs when you want CIS 3.7 and 5.4 applied to those VPCs.
