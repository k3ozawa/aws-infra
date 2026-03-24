# -------------------------------------------------------------------
# AWS Chatbot: セキュリティ通知チャンネル設定（全環境共通）
# -------------------------------------------------------------------
# 事前準備: AWS Chatbot コンソールで Slack ワークスペース「ozw-bot-workspace」を
# 接続し、slack_workspace_id と slack_channel_id を確認してください。
# https://console.aws.amazon.com/chatbot/
# -------------------------------------------------------------------
resource "aws_chatbot_slack_channel_configuration" "security" {
  configuration_name = "slack-security-${var.environment}"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id

  sns_topic_arns = [aws_sns_topic.security.arn]

  logging_level = "ERROR"

  tags = {
    Environment = var.environment
    Purpose     = "security-notifications"
  }
}

# -------------------------------------------------------------------
# AWS Chatbot: コスト通知チャンネル設定（management のみ）
# -------------------------------------------------------------------
resource "aws_chatbot_slack_channel_configuration" "cost" {
  count = var.enable_cost_notifications ? 1 : 0

  configuration_name = "slack-cost-${var.environment}"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id

  sns_topic_arns = [aws_sns_topic.cost[0].arn]

  logging_level = "ERROR"

  tags = {
    Environment = var.environment
    Purpose     = "cost-notifications"
  }
}
