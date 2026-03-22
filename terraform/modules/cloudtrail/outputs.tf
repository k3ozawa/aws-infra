output "trail_arn" {
  description = "CloudTrail 証跡の ARN"
  value       = aws_cloudtrail.organization.arn
}

output "log_bucket_name" {
  description = "CloudTrail ログ保存用 S3 バケット名"
  value       = module.cloudtrail_bucket.s3_bucket_id
}
