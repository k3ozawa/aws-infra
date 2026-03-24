# -------------------------------------------------------------------
# AWS Budgets: 月次予算アラート（management のみ）
# 80% 実績超過 / 100% 予測超過 で通知
# -------------------------------------------------------------------
resource "aws_budgets_budget" "monthly" {
  count = var.enable_cost_notifications ? 1 : 0

  name         = "monthly-budget-${var.environment}"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.cost[0].arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [aws_sns_topic.cost[0].arn]
  }
}

# -------------------------------------------------------------------
# Cost Anomaly Detection: 異常コストスパイク検知（management のみ）
# -------------------------------------------------------------------
resource "aws_ce_anomaly_monitor" "this" {
  count = var.enable_cost_notifications ? 1 : 0

  name              = "cost-anomaly-monitor-${var.environment}"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "this" {
  count = var.enable_cost_notifications ? 1 : 0

  name      = "cost-anomaly-subscription-${var.environment}"
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.this[0].arn]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.cost[0].arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.cost_anomaly_threshold)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}
