terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------
# S3 バケット: state バケットのアクセスログ保存用
# kics-scan ignore-block: このバケット自身のアクセスログを有効化すると循環ロギングになるため意図的に無効
# -------------------------------------------------------------------
module "state_access_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.state_bucket_name}-access-logs"

  versioning = {
    enabled = true
  }

  attach_deny_insecure_transport_policy = true
  attach_access_log_delivery_policy     = true
  access_log_delivery_policy_source_buckets = [
    "arn:aws:s3:::${var.state_bucket_name}",
  ]

  force_destroy = true

  tags = {
    ManagedBy = "terraform"
    Purpose   = "state-access-logs"
  }
}

# -------------------------------------------------------------------
# S3 バケット: Terraform state 保存用
# -------------------------------------------------------------------
module "terraform_state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = var.state_bucket_name

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  }

  attach_deny_insecure_transport_policy = true

  logging = {
    target_bucket = module.state_access_logs_bucket.s3_bucket_id
    target_prefix = "access-logs/"
  }

  tags = {
    Name      = var.state_bucket_name
    ManagedBy = "terraform"
    Purpose   = "terraform-state"
  }
}

# -------------------------------------------------------------------
# IAM ロール: Terraform 実行用
# -------------------------------------------------------------------
module "terraform_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  role_name   = var.terraform_execution_role_name

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    ManagedBy = "terraform"
    Purpose   = "terraform-execution"
  }
}

# -------------------------------------------------------------------
# OIDC プロバイダ + IAM ロール: GitHub Actions 用
# github_repository が設定されている場合のみ作成
# -------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.github_repository != "" ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    ManagedBy = "terraform"
  }
}

module "github_actions_role" {
  count   = var.github_repository != "" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true
  role_name   = "GitHubActionsRole"

  provider_url = aws_iam_openid_connect_provider.github_actions[0].url

  oidc_fully_qualified_subjects = [
    "repo:${var.github_repository}:ref:refs/heads/main",
    "repo:${var.github_repository}:pull_request",
  ]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    ManagedBy = "terraform"
    Purpose   = "github-actions"
  }
}
