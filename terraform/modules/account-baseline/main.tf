terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------------------------------------------------
# S3: アカウントレベルのパブリックアクセスブロック
# -------------------------------------------------------------------
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------------------------------
# EBS: デフォルト暗号化
# -------------------------------------------------------------------
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

# -------------------------------------------------------------------
# IAM Access Analyzer: 意図しない外部公開の検出
# -------------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "account-analyzer"
  type          = "ACCOUNT"

  tags = {
    ManagedBy = "terraform"
  }
}
