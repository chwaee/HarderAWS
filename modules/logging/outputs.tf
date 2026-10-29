output "trail_arn" {
  description = "ARN of the multi-region CloudTrail trail."
  value       = aws_cloudtrail.management.arn
}

output "bucket_arn" {
  description = "ARN of the CloudTrail log bucket."
  value       = aws_s3_bucket.cloudtrail.arn
}

output "bucket_name" {
  description = "Name of the CloudTrail log bucket."
  value       = aws_s3_bucket.cloudtrail.id
}

output "access_log_bucket_name" {
  description = "Name of the bucket that stores S3 server access logs for the trail bucket and the Config bucket."
  value       = aws_s3_bucket.access_logs.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group that receives CloudTrail events."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic that receives the CloudTrail delivery alarm."
  value       = aws_sns_topic.delivery.arn
}
