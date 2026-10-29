# Supplemental: GuardDuty detector. Not a CIS AWS Foundations Benchmark v3.0.0 control.
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
