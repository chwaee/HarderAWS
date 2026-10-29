# kms

One symmetric CMK in us-east-1 for CloudTrail, the trail CloudWatch log group, the delivery SNS topic, and the Config bucket. Rotation is on. CIS AWS Foundations Benchmark v3.0.0 controls 3.5 and 3.6.

The key is not the default EBS key. Resource names in the key policy match `modules/logging` and `modules/config`.
