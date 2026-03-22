variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

variable "trail_name" {
  description = "CloudTrail 証跡名"
  type        = string
  default     = "organization-trail"
}
