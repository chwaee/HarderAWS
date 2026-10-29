# Minimal example

Smallest usable setup. Every hardening flag stays at its strict default. VPC flow logs stay off until you pass VPC IDs.

From the repository root:

```bash
terraform init
terraform plan -var-file=examples/minimal/terraform.tfvars
terraform apply -var-file=examples/minimal/terraform.tfvars
```

Replace `account_id` in `terraform.tfvars` with the 12-digit account ID before you plan against a real account.
