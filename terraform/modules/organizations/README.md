# module: organizations

AWS Organizations を有効化し、組織レベルのサービスアクセスを設定するモジュール。

## 注意事項

- Organizations の有効化は **AWSコンソールで先に実施**し、Terraform でインポートする手順を推奨
- 有効化済みの場合: `terraform import aws_organizations_organization.this <organization-id>`
- `feature_set = "ALL"` が必要（SCPs など全機能を利用するため）

## Inputs

このモジュールは現時点で入力変数を持たない。

## Outputs

| 名前 | 説明 |
|---|---|
| `organization_id` | 組織 ID（例: `o-xxxxxxxxxx`） |
| `management_account_id` | 管理アカウント ID |
| `organization_arn` | 組織 ARN |
