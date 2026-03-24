# -------------------------------------------------------------------
# EventBridge: Security Hub HIGH/CRITICAL findings → SNS
# -------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "security_hub" {
  name        = "security-hub-findings-${var.environment}"
  description = "Security Hub の HIGH/CRITICAL findings を Slack に通知"

  event_pattern = jsonencode({
    source        = ["aws.securityhub"]
    "detail-type" = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity    = { Label = ["HIGH", "CRITICAL"] }
        Workflow    = { Status = ["NEW"] }
        RecordState = ["ACTIVE"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "security_hub" {
  rule      = aws_cloudwatch_event_rule.security_hub.name
  target_id = "security-hub-to-sns"
  arn       = aws_sns_topic.security.arn
}

# -------------------------------------------------------------------
# EventBridge: GuardDuty HIGH/CRITICAL findings → SNS
# severity: 7.0以上 = HIGH(7-8.9), CRITICAL(9-10)
# -------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "guardduty-findings-${var.environment}"
  description = "GuardDuty の HIGH/CRITICAL findings を Slack に通知"

  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty" {
  rule      = aws_cloudwatch_event_rule.guardduty.name
  target_id = "guardduty-to-sns"
  arn       = aws_sns_topic.security.arn
}

# -------------------------------------------------------------------
# EventBridge: AWS Config 非準拠リソース → SNS
# -------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "config_compliance" {
  name        = "config-non-compliant-${var.environment}"
  description = "AWS Config の非準拠リソースを Slack に通知"

  event_pattern = jsonencode({
    source        = ["aws.config"]
    "detail-type" = ["Config Rules Compliance Change"]
    detail = {
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "config_compliance" {
  rule      = aws_cloudwatch_event_rule.config_compliance.name
  target_id = "config-to-sns"
  arn       = aws_sns_topic.security.arn
}

# -------------------------------------------------------------------
# EventBridge: IAM Access Analyzer findings → SNS
# -------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "access_analyzer" {
  name        = "access-analyzer-findings-${var.environment}"
  description = "IAM Access Analyzer の findings を Slack に通知"

  event_pattern = jsonencode({
    source        = ["aws.access-analyzer"]
    "detail-type" = ["Access Analyzer Finding"]
  })
}

resource "aws_cloudwatch_event_target" "access_analyzer" {
  rule      = aws_cloudwatch_event_rule.access_analyzer.name
  target_id = "access-analyzer-to-sns"
  arn       = aws_sns_topic.security.arn
}
