resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "sso.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]
}

# -------------------------------------------------------------------
# OU
# -------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "dev" {
  name      = "dev"
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "prod"
  parent_id = aws_organizations_organization.this.roots[0].id
}

# -------------------------------------------------------------------
# 子アカウント
# -------------------------------------------------------------------
resource "aws_organizations_account" "dev" {
  name      = "dev"
  email     = var.dev_account_email
  parent_id = aws_organizations_organizational_unit.dev.id
}

resource "aws_organizations_account" "prod" {
  name      = "prod"
  email     = var.prod_account_email
  parent_id = aws_organizations_organizational_unit.prod.id
}

# -------------------------------------------------------------------
# SCP: root アカウント操作禁止（組織全体）
# -------------------------------------------------------------------
resource "aws_organizations_policy" "deny_root" {
  name        = "DenyRootAccountUsage"
  description = "Deny all actions by root account"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyRootAccountUsage"
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
      Condition = {
        StringLike = {
          "aws:PrincipalArn" = "arn:aws:iam::*:root"
        }
      }
    }]
  })
}

resource "aws_organizations_policy_attachment" "deny_root" {
  policy_id = aws_organizations_policy.deny_root.id
  target_id = aws_organizations_organization.this.roots[0].id
}

# -------------------------------------------------------------------
# SCP: CloudTrail 無効化禁止（組織全体）
# -------------------------------------------------------------------
resource "aws_organizations_policy" "deny_cloudtrail_disable" {
  name        = "DenyCloudTrailDisable"
  description = "Deny disabling or modifying CloudTrail"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyCloudTrailDisable"
      Effect = "Deny"
      Action = [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "cloudtrail:PutEventSelectors",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_disable" {
  policy_id = aws_organizations_policy.deny_cloudtrail_disable.id
  target_id = aws_organizations_organization.this.roots[0].id
}

# -------------------------------------------------------------------
# SCP: 利用リージョン制限（dev/prod OU）
# 許可: ap-northeast-1, ap-northeast-3, us-east-1, us-west-2
# -------------------------------------------------------------------
resource "aws_organizations_policy" "deny_non_approved_regions" {
  name        = "DenyNonApprovedRegions"
  description = "Deny access to non-approved regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyNonApprovedRegions"
      Effect = "Deny"
      NotAction = [
        "iam:*",
        "sts:*",
        "organizations:*",
        "route53:*",
        "cloudfront:*",
        "waf:*",
        "wafv2:*",
        "shield:*",
        "support:*",
        "health:*",
        "budgets:*",
        "ce:*",
        "cur:*",
        "pricing:*",
        "trustedadvisor:*",
        "account:*",
      ]
      Resource = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = [
            "ap-northeast-1",
            "ap-northeast-3",
            "us-east-1",
            "us-west-2",
          ]
        }
      }
    }]
  })
}

resource "aws_organizations_policy_attachment" "deny_non_approved_regions_dev" {
  policy_id = aws_organizations_policy.deny_non_approved_regions.id
  target_id = aws_organizations_organizational_unit.dev.id
}

resource "aws_organizations_policy_attachment" "deny_non_approved_regions_prod" {
  policy_id = aws_organizations_policy.deny_non_approved_regions.id
  target_id = aws_organizations_organizational_unit.prod.id
}
