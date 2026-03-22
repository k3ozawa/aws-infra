# module: iam-identity-center

IAM Identity Center (SSO) の Permission Set を管理するモジュール。
Organizations 有効化後に AWS が自動で Identity Center を有効化するため、このモジュールでは設定のみを行う。

## 前提条件

- AWS Organizations が `ALL` feature set で有効化済みであること

## 管理対象

- Permission Set（AdministratorAccess）
- ユーザー・グループへの割り当ては今後追加予定

## Inputs

このモジュールは現時点で入力変数を持たない。

## Outputs

| 名前 | 説明 |
|---|---|
| `sso_instance_arn` | Identity Center インスタンス ARN |
| `administrator_permission_set_arn` | AdministratorAccess Permission Set の ARN |
