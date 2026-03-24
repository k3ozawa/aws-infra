variable "slack_workspace_id" {
  description = "Slack ワークスペース ID（AWS Chatbot コンソールで接続後に確認）"
  type        = string
}

variable "slack_channel_id" {
  description = "通知先 Slack チャンネル ID"
  type        = string
}

variable "environment" {
  description = "環境名 (management / dev / prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "account_id" {
  description = "AWS アカウント ID"
  type        = string
}

variable "enable_cost_notifications" {
  description = "コスト通知を有効化するか（management アカウントのみ true）"
  type        = bool
  default     = false
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
