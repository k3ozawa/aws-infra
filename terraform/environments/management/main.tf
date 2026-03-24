# -------------------------------------------------------------------
# AWS Organizations
# -------------------------------------------------------------------
module "organizations" {
  source = "../../modules/organizations"

  dev_account_email  = var.dev_account_email
  prod_account_email = var.prod_account_email
}

# -------------------------------------------------------------------
# IAM Identity Center (SSO)
# -------------------------------------------------------------------
module "iam_identity_center" {
  source = "../../modules/iam-identity-center"

  depends_on = [module.organizations]
}

# -------------------------------------------------------------------
# CloudTrail（組織レベル）
# -------------------------------------------------------------------
module "cloudtrail" {
  source = "../../modules/cloudtrail"

  aws_region = var.aws_region

  depends_on = [module.organizations]
}

# -------------------------------------------------------------------
# Slack 通知（コスト + セキュリティガバナンス）
# -------------------------------------------------------------------
module "slack_notifications" {
  source = "../../modules/slack-notifications"

  environment               = "management"
  aws_region                = var.aws_region
  account_id                = var.account_id
  slack_workspace_id        = var.slack_workspace_id
  slack_channel_id          = var.slack_channel_id
  enable_cost_notifications = true
  monthly_budget_amount     = var.monthly_budget_amount
  cost_anomaly_threshold    = var.cost_anomaly_threshold

  depends_on = [module.organizations]
}
