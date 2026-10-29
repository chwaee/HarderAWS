data "aws_region" "current" {}

# CIS: 1.20
resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "harderaws-${var.environment}-${data.aws_region.current.name}"
  type          = "ACCOUNT"
}
