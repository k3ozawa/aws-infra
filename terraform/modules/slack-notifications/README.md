# slack-notifications モジュール

AWS アカウント（management / dev / prod）から Slack ワークスペース **ozw-bot-workspace** へ
コスト通知・セキュリティガバナンス通知を送信するモジュールです。

## 通知内容

### コスト通知（management アカウントのみ）
| サービス | 通知トリガー |
|---------|------------|
| AWS Budgets | 月次予算の 80% 超過（実績）／ 100% 超過（予測） |
| Cost Anomaly Detection | サービス単位でのコスト異常（閾値: デフォルト $5） |

### セキュリティ通知（全アカウント共通）
| サービス | 通知トリガー |
|---------|------------|
| Security Hub | severity: HIGH / CRITICAL の新規 finding |
| GuardDuty | severity >= 7（HIGH / CRITICAL）の finding |
| AWS Config | 非準拠（NON_COMPLIANT）リソースの検出 |
| IAM Access Analyzer | 外部公開アクセスの検出 |

## 事前準備

1. **AWS Chatbot コンソール**で Slack ワークスペース「ozw-bot-workspace」を接続する  
   https://console.aws.amazon.com/chatbot/

2. 接続後に表示される **Workspace ID**（例: `T0XXXXXXXX`）と  
   通知先 **チャンネル ID**（例: `C0XXXXXXXXX`）を確認する

3. 各環境の `.tfvars` に値を設定する

## 使用例

```hcl
# management アカウント（コスト + セキュリティ通知）
module "slack_notifications" {
  source = "../../modules/slack-notifications"

  environment               = "management"
  aws_region                = var.aws_region
  account_id                = var.account_id
  slack_workspace_id        = var.slack_workspace_id
  slack_channel_id          = var.slack_channel_id
  enable_cost_notifications = true
  monthly_budget_amount     = 10
  cost_anomaly_threshold    = 5
}

# dev / prod アカウント（セキュリティ通知のみ）
module "slack_notifications" {
  source = "../../modules/slack-notifications"

  environment        = "dev"
  aws_region         = var.aws_region
  account_id         = var.account_id
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id
}
```

## 必須変数

| 変数 | 説明 |
|------|------|
| `slack_workspace_id` | Slack ワークスペース ID（AWS Chatbot で確認） |
| `slack_channel_id` | 通知先 Slack チャンネル ID |
| `environment` | 環境名（management / dev / prod） |
| `account_id` | AWS アカウント ID |
