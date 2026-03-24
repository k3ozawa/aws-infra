variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "dev_account_email" {
  description = "dev アカウントのメールアドレス"
  type        = string
}

variable "prod_account_email" {
  description = "prod アカウントのメールアドレス"
  type        = string
}

variable "account_id" {
  description = "management アカウント ID"
  type        = string
}

# -------------------------------------------------------------------
# Slack 通知設定
# AWS Chatbot コンソールで Slack ワークスペースを接続後に設定
# https://console.aws.amazon.com/chatbot/
# -------------------------------------------------------------------
variable "slack_workspace_id" {
  description = "Slack ワークスペース ID（AWS Chatbot コンソールで確認）"
  type        = string
}

variable "slack_channel_id" {
  description = "通知先 Slack チャンネル ID"
  type        = string
}

variable "monthly_budget_amount" {
  description = "月次予算アラートの閾値（USD）"
  type        = number
  default     = 10
}

variable "cost_anomaly_threshold" {
  description = "コスト異常検知の閾値（USD）"
  type        = number
  default     = 5
}
