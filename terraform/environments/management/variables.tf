variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "organization_email_domain" {
  description = "Organizations のメールアドレスドメイン（例: example.com）"
  type        = string
}

variable "dev_account_email" {
  description = "dev アカウントのメールアドレス"
  type        = string
}

variable "prod_account_email" {
  description = "prod アカウントのメールアドレス"
  type        = string
}
