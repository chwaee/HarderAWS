# logging

Multi-region CloudTrail with log file validation, a KMS-encrypted bucket, CloudWatch Logs, and an alarm when delivery stops. CIS AWS Foundations Benchmark v3.0.0 controls 3.1, 3.2, 3.4, and 3.5.

The access-log bucket also accepts server access logs from the Config bucket. That bucket name is computed, so this module does not depend on the config module.
