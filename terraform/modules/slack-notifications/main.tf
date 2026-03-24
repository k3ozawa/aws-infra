terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.27"
    }
  }
}

# -------------------------------------------------------------------
# SNS: セキュリティ通知トピック（全環境共通）
# -------------------------------------------------------------------
resource "aws_sns_topic" "security" {
  name = "slack-security-notifications-${var.environment}"

  tags = {
    Environment = var.environment
    Purpose     = "security-notifications"
  }
}

resource "aws_sns_topic_policy" "security" {
  arn = aws_sns_topic.security.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.security.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:events:${var.aws_region}:${var.account_id}:rule/*"
          }
        }
      }
    ]
  })
}

# -------------------------------------------------------------------
# SNS: コスト通知トピック（management のみ）
# -------------------------------------------------------------------
resource "aws_sns_topic" "cost" {
  count = var.enable_cost_notifications ? 1 : 0

  name = "slack-cost-notifications-${var.environment}"

  tags = {
    Environment = var.environment
    Purpose     = "cost-notifications"
  }
}

resource "aws_sns_topic_policy" "cost" {
  count = var.enable_cost_notifications ? 1 : 0
  arn   = aws_sns_topic.cost[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBudgetsPublish"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost[0].arn
      },
      {
        Sid    = "AllowCostExplorerPublish"
        Effect = "Allow"
        Principal = {
          Service = "ce.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost[0].arn
      }
    ]
  })
}

# -------------------------------------------------------------------
# IAM: AWS Chatbot 実行ロール
# -------------------------------------------------------------------
resource "aws_iam_role" "chatbot" {
  name = "aws-chatbot-slack-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_read_only" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "chatbot_cloudwatch" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
