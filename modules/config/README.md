# config

AWS Config recorder and delivery channel for one region. The home-region instance creates the bucket and the service-linked role. Other regions deliver into that bucket.

CIS AWS Foundations Benchmark v3.0.0 control 3.3. Global resource types are recorded in one region only, which is an AWS limit.
