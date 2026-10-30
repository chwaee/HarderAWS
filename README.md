# HarderAWS

Opinionated AWS security hardening as Terraform 1.5+ modules. The root module wires one submodule per control domain: IAM, logging, CloudWatch CIS alarms, S3 guardrails, KMS, VPC, Config, GuardDuty, Access Analyzer, and default EBS encryption.

This is a security posture layer. It creates policies, trails, security buckets, encryption defaults, and templates. It does not create databases, instances, application buckets, or organization resources.

Author: Chwaee ([chwaee](https://github.com/chwaee), hello@appliedaiconsulting.io). License: MIT.

## Related tools

| Tool | Use it for |
| --- | --- |
| [aws-health-audit](https://github.com/chwaee/aws-health-audit) | Read-only AWS audit before you apply anything |
| [tf-cost-preview](https://github.com/chwaee/tf-cost-preview) | Estimate monthly cost of this plan before apply |
| [secure-ci-templates](https://github.com/chwaee/secure-ci-templates) | GitHub Actions workflows for client repos |
| [appliedaiconsulting.io](https://appliedaiconsulting.io) | Consulting services |

## What it does

| Module | What it creates | CIS v3.0.0 |
| --- | --- | --- |
| `modules/iam` | Password policy, `HardenedAdmins` group, constrained admin policy, MFA deny policy, support role, SCP JSON output | 1.8, 1.9, 1.10, 1.15, 1.16, 1.17 |
| `modules/logging` | Multi-region CloudTrail, log bucket, access-log bucket, CloudWatch log group, delivery alarm | 3.1, 3.2, 3.4, 3.5, and 2.1.1 on those buckets |
| `modules/cloudwatch-alarms` | Metric filters and alarms for CIS Section 4 on the CloudTrail log group | 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 4.11, 4.12, 4.13, 4.14, 4.15 |
| `modules/s3-guardrails` | Account-level S3 Block Public Access, all four settings | 2.1.4 |
| `modules/kms` | One CMK for CloudTrail, the trail log group, the delivery topic, and Config, with rotation | 3.5, 3.6 |
| `modules/vpc` | IMDSv2 launch template, instance profile, opt-in flow logs, default security group with no rules | 1.18, 3.7, 5.4, 5.6 |
| `modules/config` | AWS Config recorder and delivery channel in us-east-1 and one more region | 3.3 |
| `modules/guardduty` | GuardDuty detector in us-east-1 and one more region | Supplemental. Not in this benchmark |
| `modules/access-analyzer` | IAM Access Analyzer in us-east-1 and one more region | 1.20 |
| `modules/ebs-default-encryption` | Default EBS encryption in us-east-1 and one more region | 2.2.1 |

Control numbers follow CIS AWS Foundations Benchmark v3.0.0. A few IDs that show up in older write-ups are different here: Access Analyzer is 1.20, Config is 3.3, and CMK rotation is 3.6. GuardDuty is not control 16.2. That ID is not in this benchmark.

Resources that implement a control carry a `# CIS:` comment.

## Prerequisites

- Terraform 1.5 or newer. CI uses 1.9.8.
- AWS provider `hashicorp/aws` 5.70 up to, and not including, 6.0.
- An AWS account, and credentials for the principal that will apply the stack.
- For `terraform validate` only, credentials are not required.

The principal that applies this stack needs permission to create IAM policies, CloudTrail, Config, GuardDuty, KMS keys, SNS topics, CloudWatch log groups and alarms, S3 buckets, and the account-level S3 and EBS settings. The CMK key policy delegates administration to IAM in the account. It does not grant access to the public.

## Quick start

From the repository root, using the minimal example:

```bash
terraform init
terraform plan -var-file=examples/minimal/terraform.tfvars
terraform apply -var-file=examples/minimal/terraform.tfvars
```

Replace `account_id` in the tfvars file with the 12-digit account ID before you plan against a real account. The placeholder `123456789012` is there so the file parses.

The full flag set is in `examples/cis-compliance`.

```bash
terraform plan -var-file=examples/cis-compliance/terraform.tfvars
```

Copy `backend.tf.example` to `backend.tf` when you want remote state. Until you do that, state stays local.

## Variables

| Name | Type | Default | Purpose |
| --- | --- | --- | --- |
| `environment` | string | `production` | Name segment and tag. Lowercase letters, digits, and hyphens. |
| `enable_cis_logging` | bool | `true` | CloudTrail, log buckets, log group, delivery alarm, and the CMK when Config is also off. |
| `enable_cis_alarms` | bool | `true` | CIS 4.1–4.15 metric filters and alarms. Created only when logging is also on. |
| `enable_cis_iam` | bool | `true` | Password policy, admin group, support role, Access Analyzer. |
| `enable_cis_networking` | bool | `true` | IMDSv2 launch template. Flow logs and default security groups only when VPC IDs are set or discovery is on. |
| `enable_cis_encryption` | bool | `true` | Default EBS encryption in both regions. |
| `enable_guardduty` | bool | `true` | GuardDuty detector in both regions. |
| `enable_config` | bool | `true` | AWS Config recorder in both regions. Also creates the CMK when logging is off. |
| `additional_regions` | list(string) | `["us-west-2"]` | Exactly one region besides us-east-1. |
| `account_id` | string | none | 12-digit account ID. Required. |
| `admin_group_name` | string | `HardenedAdmins` | Group that receives the constrained policies. No users are created. |
| `vpc_ids` | list(string) | `[]` | VPC IDs in us-east-1 for flow logs and default security group cleanup. |
| `additional_region_vpc_ids` | list(string) | `[]` | Same, for the additional region. |
| `discover_vpcs` | bool | `false` | When true, do that work for every VPC visible in both regions. |

Account-level S3 Block Public Access is always on. There is no flag for it.

Home region is `us-east-1`. Terraform cannot build provider aliases from a list of unknown length, so this stack wires exactly one extra region.

The password policy sets minimum length 14, upper and lower case, numbers, symbols, a 90-day maximum age, and reuse prevention of 24. `hard_expiry` is false, so a user with an expired password can still change it. IAM has no failed-attempt lockout, so a threshold of 3 is not set.

## Outputs

| Name | Meaning |
| --- | --- |
| `cloudtrail_trail_arn` | Multi-region trail ARN. |
| `cloudtrail_bucket_arn` | Trail log bucket ARN. |
| `alarm_name_cis_4_1` | CIS 4.1 unauthorized API calls alarm. |
| `alarm_name_cis_4_2` | CIS 4.2 console sign-in without MFA alarm. |
| `alarm_name_cis_4_3` | CIS 4.3 root account use alarm. |
| `alarm_name_cis_4_4` | CIS 4.4 IAM policy changes alarm. |
| `alarm_name_cis_4_5` | CIS 4.5 CloudTrail configuration changes alarm. |
| `alarm_name_cis_4_6` | CIS 4.6 console authentication failures alarm. |
| `alarm_name_cis_4_7` | CIS 4.7 CMK disable or scheduled deletion alarm. |
| `alarm_name_cis_4_8` | CIS 4.8 S3 bucket policy changes alarm. |
| `alarm_name_cis_4_9` | CIS 4.9 AWS Config changes alarm. |
| `alarm_name_cis_4_10` | CIS 4.10 security group changes alarm. |
| `alarm_name_cis_4_11` | CIS 4.11 NACL changes alarm. |
| `alarm_name_cis_4_12` | CIS 4.12 network gateway changes alarm. |
| `alarm_name_cis_4_13` | CIS 4.13 route table changes alarm. |
| `alarm_name_cis_4_14` | CIS 4.14 VPC changes alarm. |
| `alarm_name_cis_4_15` | CIS 4.15 AWS Organizations changes alarm. |
| `config_recorder_name` | Recorder name in us-east-1. |
| `config_recorder_names` | Recorder names keyed by region. |
| `guardduty_detector_id` | Detector ID in us-east-1. |
| `guardduty_detector_ids` | Detector IDs keyed by region. |
| `kms_key_arn` | CMK used for CloudTrail and Config. |
| `flow_log_ids` | Flow log IDs across both regions. Empty until VPCs are opted in. |
| `access_analyzer_arn` | Analyzer ARN in us-east-1. |
| `access_analyzer_arns` | Analyzer ARNs keyed by region. |
| `admin_group_name` | Constrained admin group name. |
| `scp_policy_document` | JSON SCP. Not attached by this stack. |
| `imdsv2_launch_template_id` | Launch template ID in us-east-1. |
| `imdsv2_launch_template_ids` | Launch template IDs keyed by region. |

Outputs are null or empty when the feature is turned off.

## Control coverage

Status is **Implemented** when the stack creates the control for the regions it manages, **Partial** when the control is preventive or limited to two regions or to VPCs you name, and **Not in scope** when this repository does not try to satisfy it.

| Control | Description | Module | Status |
| --- | --- | --- | --- |
| 1.1 | Maintain current contact details | — | Not in scope |
| 1.2 | Security contact information is registered | — | Not in scope |
| 1.3 | Security questions are registered | — | Not in scope |
| 1.4 | No root user access key | — | Not in scope |
| 1.5 | MFA is enabled for the root user | — | Not in scope |
| 1.6 | Hardware MFA is enabled for the root user | — | Not in scope |
| 1.7 | Root user is not used for daily tasks | — | Not in scope |
| 1.8 | Password policy minimum length 14 | iam | Implemented |
| 1.9 | Password policy prevents reuse | iam | Implemented |
| 1.10 | MFA for every IAM user with a console password | iam | Partial. Deny-without-MFA is attached to HardenedAdmins. Existing users are not enrolled. |
| 1.11 | No access keys at initial user setup | iam | Partial. This stack creates no users and no access keys. It does not audit existing users. |
| 1.12 | Credentials unused for 45 days are disabled | — | Not in scope |
| 1.13 | Only one active access key per user | — | Not in scope |
| 1.14 | Access keys rotated every 90 days | — | Not in scope |
| 1.15 | Users receive permissions only through groups | iam | Partial. Policies this stack creates are attached to the group only. Existing user policies are left in place. |
| 1.16 | No IAM policy grants full `*:*` administration | iam | Partial. The admin policy is an explicit action list, not AdministratorAccess. Existing admin policies are not detached. The SCP output denies attaching AdministratorAccess and IAMFullAccess. |
| 1.17 | Support role for incident management | iam | Implemented |
| 1.18 | Instances use IAM roles | vpc | Partial. The launch template references an instance profile. Existing instances are not changed. |
| 1.19 | Expired IAM server certificates are removed | — | Not in scope |
| 1.20 | IAM Access Analyzer is enabled in all regions | access-analyzer | Partial. Enabled in us-east-1 and the additional region. |
| 1.21 | Users are federated in multi-account environments | — | Not in scope |
| 1.22 | AWSCloudShellFullAccess is restricted | — | Not in scope |
| 2.1.1 | S3 bucket policy denies HTTP | logging, config | Partial. Module buckets deny non-TLS. The SCP output denies `s3:*` without TLS for the whole account once an admin attaches it. |
| 2.1.2 | MFA Delete on S3 buckets | — | Not in scope |
| 2.1.3 | S3 data is discovered and classified | — | Not in scope |
| 2.1.4 | S3 Block Public Access | s3-guardrails | Implemented at account level, and on every bucket this stack creates. |
| 2.2.1 | EBS default encryption in all regions | ebs-default-encryption | Partial. us-east-1 and the additional region. Uses `alias/aws/ebs`. |
| 2.3.1 | RDS encryption at rest | — | Not in scope |
| 2.3.2 | RDS automatic minor version upgrade | — | Not in scope |
| 2.3.3 | RDS is not publicly accessible | — | Not in scope |
| 2.4.1 | EFS encryption | — | Not in scope |
| 3.1 | CloudTrail enabled in all regions | logging | Implemented. One multi-region trail, global service events included. |
| 3.2 | CloudTrail log file validation | logging | Implemented |
| 3.3 | AWS Config enabled in all regions | config | Partial. us-east-1 and the additional region. Global resource types are recorded in us-east-1 only. |
| 3.4 | Access logging on the CloudTrail bucket | logging | Implemented |
| 3.5 | CloudTrail logs encrypted with a CMK | kms, logging | Implemented |
| 3.6 | Rotation for customer CMKs | kms | Implemented |
| 3.7 | VPC flow logs in all VPCs | vpc | Partial. Opt-in by VPC ID, or `discover_vpcs`. |
| 3.8 | S3 object-level write events | — | Not in scope |
| 3.9 | S3 object-level read events | — | Not in scope |
| 4.1 | Metric filter and alarm for unauthorized API calls | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.2 | Metric filter and alarm for console sign-in without MFA | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.3 | Metric filter and alarm for root account use | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.4 | Metric filter and alarm for IAM policy changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.5 | Metric filter and alarm for CloudTrail configuration changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.6 | Metric filter and alarm for console authentication failures | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.7 | Metric filter and alarm for CMK disable or scheduled deletion | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.8 | Metric filter and alarm for S3 bucket policy changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.9 | Metric filter and alarm for AWS Config changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.10 | Metric filter and alarm for security group changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.11 | Metric filter and alarm for NACL changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.12 | Metric filter and alarm for network gateway changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.13 | Metric filter and alarm for route table changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.14 | Metric filter and alarm for VPC changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.15 | Metric filter and alarm for AWS Organizations changes | cloudwatch-alarms | Partial. Metric filters and alarms in us-east-1 only. Alarms use SNS topic from logging module. |
| 4.16 | Security Hub is enabled | — | Not in scope |
| 5.1 | No NACL allows admin ports from 0.0.0.0/0 | — | Not in scope |
| 5.2 | No security group allows admin ports from 0.0.0.0/0 | — | Not in scope |
| 5.3 | No security group allows admin ports from ::/0 | — | Not in scope |
| 5.4 | Default security group restricts all traffic | vpc | Partial. No ingress and no egress, for opted-in VPCs only. |
| 5.5 | VPC peering routes are least access | — | Not in scope |
| 5.6 | EC2 metadata service allows IMDSv2 only | vpc | Partial. Launch template sets `http_tokens` to required. Existing instances are not changed. |

GuardDuty is enabled in us-east-1 and the additional region as extra coverage. It is not one of the 62 CIS AWS Foundations Benchmark v3.0.0 controls.

The password policy also requires symbols, numbers, and both cases, and it expires passwords at 90 days. Those settings do not have their own v3.0.0 control IDs. They are still applied.

## Limitations

- The SCP is a JSON output. Attaching it needs AWS Organizations, which this stack does not call. Before you attach it, replace `REPLACE_WITH_BREAK_GLASS_ROLE` with the role your pipeline assumes. Until you do, nobody is exempt. The deny list includes `cloudtrail:UpdateTrail` and `guardduty:UpdateDetector`, so a later Terraform apply can fail once the SCP is attached unless the pipeline role is exempt. The document does not deny the root user, so attaching it cannot by itself lock root out of the account.
- One extra region. Covering every AWS region means more provider aliases than this root defines.
- No multi-account loop. Run the stack once per account, with that account's own state.
- State is not forced to a backend in this repository. Use `backend.tf.example` and a key such as `harderaws/terraform.tfstate` so application state stays in a different file.
- Account S3 Block Public Access does not delete buckets. It does make public buckets private, including buckets this stack did not create.
- `terraform destroy` deletes the guardrails this stack created, including the trail and the CMK (after the 30-day waiting period). It does not delete application resources. Buckets with objects are not force-destroyed. Empty them before destroy if you intend to remove them.
- CloudTrail, Config, GuardDuty, and Access Analyzer allow one of each per account per region. If one already exists, apply fails rather than deleting the existing one. Import it, or disable that module.
- The Config service-linked role is global. If the account already has it, import `aws_iam_service_linked_role.config` or the home-region apply fails.
- VPC discovery is off by default. A default apply does not change existing VPC security groups or add flow logs.
- IAM password policy replaces the account password policy in place. It does not delete users. There is no lockout threshold to set.
- CIS Section 4 alarms cover us-east-1 only. S3 object-level data events, Macie, RDS, and EFS are not built.
- Security buckets store CloudTrail and Config data. They are not application buckets. Log storage has a cost. This stack does not tune that cost.

## Development

```bash
make lint
make test
```

`make lint` checks formatting, runs tflint with the AWS ruleset, and runs tfsec at high severity and above. `make test` runs lint and `tests/test_hcl.sh`, which runs `terraform init -backend=false` and `terraform validate` at the root and in each submodule.

CI on push and pull request runs the same checks.

## Consulting

Need this applied to your account with a gap analysis? Contact me at hello@appliedaiconsulting.io.
