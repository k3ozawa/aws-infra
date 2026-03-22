variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "state_bucket_name" {
  description = "Terraform state を保存する S3 バケット名（グローバルで一意）"
  type        = string
}

variable "terraform_execution_role_name" {
  description = "Terraform 実行用 IAM ロール名"
  type        = string
  default     = "TerraformExecutionRole"
}

variable "github_repository" {
  description = "GitHub リポジトリ（owner/repo 形式、例: username/aws-infra）"
  type        = string
  default     = ""
}
