variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "account_id" {
  description = "prod アカウント ID"
  type        = string
}

# -------------------------------------------------------------------
# Slack 通知設定
# -------------------------------------------------------------------
variable "slack_workspace_id" {
  description = "Slack ワークスペース ID（AWS Chatbot コンソールで確認）"
  type        = string
}

variable "slack_channel_id" {
  description = "通知先 Slack チャンネル ID"
  type        = string
}
