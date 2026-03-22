terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------
# S3 バケット: CloudTrail バケットのアクセスログ保存用
# -------------------------------------------------------------------
module "cloudtrail_access_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${var.aws_region}-access-logs"

  attach_deny_insecure_transport_policy = true
  attach_access_log_delivery_policy     = true
  access_log_delivery_policy_source_buckets = [
    "arn:aws:s3:::cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${var.aws_region}",
  ]

  force_destroy = true

  tags = {
    ManagedBy = "terraform"
    Purpose   = "cloudtrail-access-logs"
  }
}

# -------------------------------------------------------------------
# S3 バケット: CloudTrail ログ保存用
# -------------------------------------------------------------------
module "cloudtrail_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

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

  force_destroy = true

  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.cloudtrail_s3.json
  attach_deny_insecure_transport_policy = true

  logging = {
    target_bucket = module.cloudtrail_access_logs_bucket.s3_bucket_id
    target_prefix = "access-logs/"
  }

  tags = {
    ManagedBy = "terraform"
    Purpose   = "cloudtrail-logs"
  }
}

data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${var.aws_region}"]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${var.aws_region}/AWSLogs/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# -------------------------------------------------------------------
# CloudTrail: 組織レベルの証跡
# -------------------------------------------------------------------
resource "aws_cloudtrail" "organization" {
  name                          = var.trail_name
  s3_bucket_name                = module.cloudtrail_bucket.s3_bucket_id
  is_multi_region_trail         = true
  is_organization_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  tags = {
    ManagedBy = "terraform"
    Purpose   = "organization-audit"
  }
}
