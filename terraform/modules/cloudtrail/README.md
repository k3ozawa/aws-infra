# module: cloudtrail

組織レベルの CloudTrail 証跡を管理するモジュール。
全アカウント・全リージョンのAPI呼び出しを管理アカウントの S3 バケットに集約する。

## 前提条件

- AWS Organizations が有効化済みであること
- `cloudtrail.amazonaws.com` が Organizations の信頼されたサービスとして有効化済みであること

## Inputs

| 名前 | 説明 | 必須 | デフォルト |
|---|---|---|---|
| `management_account_id` | AWS 管理アカウント ID | ✅ | - |
| `aws_region` | AWSリージョン | ✅ | - |
| `trail_name` | CloudTrail 証跡名 | - | `organization-trail` |
| `log_retention_days` | CloudWatch Logs 保持期間（日） | - | `90` |

## Outputs

| 名前 | 説明 |
|---|---|
| `trail_arn` | CloudTrail 証跡の ARN |
| `log_bucket_name` | ログ保存用 S3 バケット名 |
