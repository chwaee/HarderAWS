# cloudwatch-alarms

Metric filters and alarms for CIS AWS Foundations Benchmark v3.0.0 controls 4.1 through 4.15. Filters read the CloudTrail log group. Alarms publish to the SNS topic from the logging module. The root module creates them in us-east-1.

CIS 4.1 matches AccessDenied and is noisy. CIS 4.5 treats missing metric data as breaching. The other alarms use notBreaching. Set enable_all to false to create none of the filters or alarms.
