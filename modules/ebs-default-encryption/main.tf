# CIS: 2.2.1
# Uses the AWS-managed alias/aws/ebs key. This module does not create a CMK, so application volumes are not tied to the CloudTrail key.
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}
