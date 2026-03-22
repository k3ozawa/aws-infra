variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

variable "trail_name" {
  description = "CloudTrail 証跡名"
  type        = string
  default     = "organization-trail"
}

variable "log_retention_days" {
  description = "CloudWatch Logs の保持期間（日）"
  type        = number
  default     = 90
}
