# CLAUDE.md — aws-infra

AWS 組織・基盤インフラを Terraform で管理するリポジトリ。
開発方針・共通規約は [`claude-dev`](https://github.com/{username}/claude-dev) の CLAUDE.md を方針のベースとする。

---

## このリポジトリの管理対象

| リソース | ツール | 説明 |
|---|---|---|
| Terraform state バックエンド | Terraform (bootstrap) | S3 バケット + DynamoDB テーブル |
| AWS Organizations | Terraform | 組織有効化・OU構成 |
| IAM Identity Center (SSO) | Terraform | ユーザー・グループ・権限セット管理 |
| CloudTrail（組織レベル） | Terraform | 全アカウントの証跡を管理アカウントに集約 |

---

## ディレクトリ構成

```
aws-infra/
├── CLAUDE.md
├── README.md
├── .gitignore
├── .mise.toml                  # ツールバージョン + 共通環境変数（リージョン）
└── terraform/
    ├── bootstrap/              # Step 1: state管理用S3+DynamoDBをローカルstateで作成
    │   ├── .mise.toml          # AWS_PROFILE + TF_VAR_state_bucket_name
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── backend.tf          # localバックエンド（bootstrapはリモートstate不要）
    ├── environments/
    │   ├── management/         # Step 2: 管理アカウントのリソース（Organizationsなど）
    │   │   ├── .mise.toml      # アカウント固有のTF_VAR_*
    │   ├── dev/                # Step 3: dev アカウントのベースライン
    │   │   ├── .mise.toml      # TF_VAR_account_id + TF_CLI_ARGS_init
    │   └── prod/               # Step 3: prod アカウントのベースライン
    │       ├── .mise.toml      # TF_VAR_account_id + TF_CLI_ARGS_init
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       ├── provider.tf
    │       ├── backend.tf
    │       └── backend.hcl.example
    └── modules/                # 再利用可能モジュール
        ├── organizations/
        ├── iam-identity-center/
        └── cloudtrail/
```

---

## 環境変数・認証情報の管理

mise で管理する。`.env` ファイルは使用しない。

| ファイル | 管理する変数 |
|---|---|
| `.mise.toml`（ルート） | `AWS_DEFAULT_REGION`、`TF_VAR_aws_region` |
| `terraform/bootstrap/.mise.toml` | `AWS_PROFILE`、`TF_VAR_state_bucket_name` |
| `terraform/environments/<account>/.mise.toml` | `AWS_PROFILE`、アカウント固有の `TF_VAR_*` |

- `.mise.toml` は `TF_VAR_*` 変数のみ管理する。`AWS_PROFILE` は設定しない
- 新しいアカウントを `environments/` 配下に追加するときも同じパターンで `.mise.toml` を置く
- mise はディレクトリを遡って `.mise.toml` をマージするため、ルートの共通変数は自動的に引き継がれる
- terraform 実行前に `mise install` でツールバージョンを揃える
- terraform コマンドは `aws-vault exec <profile> --` でラップして実行する

```bash
aws-vault exec k3ozawa-workspace -- terraform plan
aws-vault exec k3ozawa-workspace -- terraform apply
```

**`.mise.toml` の管理ルール（パブリックリポジトリのため）**

`terraform/` 配下の `.mise.toml` はプロファイル名・ドメイン等の個人情報を含むため gitignore している。
`.mise.toml.example` をテンプレートとしてコミットし、初回セットアップ時にコピーして使う。

```bash
cp .mise.toml.example .mise.toml
# .mise.toml を編集して実際の値を記入
```

ルートの `.mise.toml` は機密情報を含まないためそのままコミットする。

---

## Terraform バージョン方針

最低バージョン: `>= 1.10.0`

このバージョンを要求する主な理由と、それにより不要になったもの：

| バージョン | 機能 | 影響 |
|---|---|---|
| 1.10 | S3 ネイティブロック (`use_lockfile = true`) | DynamoDB ロックテーブルが不要 |

**バージョンを上げる際は必ず [Terraform Changelog](https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md) を確認し、不要になるリソースや利用できる新機能がないか見直すこと。**

`renovate.json` を配置済み。GitHub リポジトリで Renovate App を有効化することで自動更新 PR が作成される。

---

## Terraform コーディング規約

- **モジュールは `terraform-aws-modules` を優先する**。`https://github.com/terraform-aws-modules` に公式モジュールがある場合はカスタムモジュールより優先して使用し、コード量を削減する
- **AWSアカウントIDは変数として定義しない**。`data "aws_caller_identity" {}` で現在の認証情報から動的に取得する

---

## 作業順序（初回セットアップ）

Terraform state管理バックエンドが存在しない状態から始めるため、以下の順序で作業する:

1. **bootstrap を実行する**（ローカル state）
   - S3 バケット + Terraform 実行用 IAM ロール (`TerraformExecutionRole`) を作成
   - state はローカルに保持（bootstrap 自体はリモート state 不要）
   - bootstrap は `AWS_PROFILE` を設定せず、実行時の IAM 認証情報（aws login 等）をそのまま使用する
   - 実行後、`terraform output terraform_execution_role_arn` で IAM ロール ARN を確認する

2. **AWS プロファイルに Assume Role 設定を追加する**
   - `~/.aws/config` に以下を追記し、以降は `terraform-execution` プロファイルで操作する
   ```ini
   [profile terraform-execution]
   source_profile = <bootstrap で使用したプロファイル>
   role_arn = <terraform_execution_role_arn の出力値>
   ```
   - 各ディレクトリの `.mise.toml` の `AWS_PROFILE` を `terraform-execution` に更新する

3. **environments/management を初期化する**（リモート state）
   - `.mise.toml` の `TF_CLI_ARGS_init` にある `bucket=` を bootstrap で作成したバケット名に書き換える
   - `aws-vault exec <profile> -- terraform init`

3. **Organizations を有効化する**
   - AWSコンソールで先に Organizations を有効化してからTerraformでインポートする

4. **IAM Identity Center を有効化する**
   - AWSコンソールで IAM Identity Center を手動で有効化する（Terraform での有効化は不可）
   - 有効化後に Terraform が SSO インスタンスを自動検出する

5. **IAM Identity Center・CloudTrail を構築する**

6. **子アカウントのセキュリティベースラインを適用する**
   - `terraform output dev_account_id` / `terraform output prod_account_id` でアカウント ID を確認する
   - `environments/dev/` と `environments/prod/` の `.mise.toml` を作成し、アカウント ID とバケット名を設定する
   - 各ディレクトリで `aws-vault exec <profile> -- terraform init && terraform apply` を実行する

---

## Claude Code への作業指示

1. 必ず `claude-dev` の CLAUDE.md を先に読み、共通規約に従う
2. `bootstrap/` は **ローカル state** のまま管理する。リモートに移行しない
3. `environments/management/` のリソースは必ずリモート state を使用する
4. `terraform plan` の出力を確認してから `apply` を実行する
