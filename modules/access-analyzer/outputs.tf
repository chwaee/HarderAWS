output "analyzer_arn" {
  description = "ARN of the account IAM Access Analyzer in this region."
  value       = aws_accessanalyzer_analyzer.account.arn
}
