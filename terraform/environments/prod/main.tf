module "account_baseline" {
  source = "../../modules/account-baseline"
}

# -------------------------------------------------------------------
# Slack 通知（セキュリティガバナンス）
# -------------------------------------------------------------------
module "slack_notifications" {
  source = "../../modules/slack-notifications"

  environment        = "prod"
  aws_region         = var.aws_region
  account_id         = var.account_id
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id
}
