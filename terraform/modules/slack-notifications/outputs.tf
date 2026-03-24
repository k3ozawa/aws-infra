output "security_sns_topic_arn" {
  description = "セキュリティ通知用 SNS トピック ARN"
  value       = aws_sns_topic.security.arn
}

output "cost_sns_topic_arn" {
  description = "コスト通知用 SNS トピック ARN（enable_cost_notifications = true のみ）"
  value       = var.enable_cost_notifications ? aws_sns_topic.cost[0].arn : null
}

output "chatbot_security_arn" {
  description = "セキュリティ通知用 Chatbot 設定 ARN"
  value       = aws_chatbot_slack_channel_configuration.security.chat_configuration_arn
}
