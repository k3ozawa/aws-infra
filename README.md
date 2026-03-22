# aws-infra

AWS 組織・基盤インフラを Terraform で管理するリポジトリ。

> 開発方針・コーディング規約・セキュリティポリシーは [claude-dev](https://github.com/{username}/claude-dev) の CLAUDE.md を参照。

---

## 管理対象リソース

| リソース | 説明 |
|---|---|
| Terraform state バックエンド | S3 バケット + DynamoDB テーブル |
| AWS Organizations | 組織有効化・サービス連携設定 |
| IAM Identity Center (SSO) | Permission Set 管理 |
| CloudTrail（組織レベル） | 全アカウントの証跡を集約 |

## ディレクトリ構成

```
aws-infra/
├── CLAUDE.md
├── README.md
├── .gitignore
└── terraform/
    ├── bootstrap/              # Step 1: state管理バックエンドの作成（ローカルstate）
    ├── environments/
    │   └── management/         # Step 2: 管理アカウントのリソース（リモートstate）
    └── modules/
        ├── organizations/
        ├── iam-identity-center/
        └── cloudtrail/
```

---

## セットアップ手順

### 前提条件

- `claude-dev` の README に従いローカル環境構築済みであること（mise / Terraform / AWS CLI）
- 管理アカウントの AWS 認証情報が設定済みであること

### Step 1: Terraform state バックエンドを作成する

```bash
cd terraform/bootstrap

cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集して S3 バケット名を記入（グローバルで一意な名前）

terraform init
terraform plan
terraform apply
```

> ⚠️ `terraform.tfvars` は `.gitignore` 済み。絶対にコミットしないこと。

### Step 2: 管理アカウントのリソースを初期化する

```bash
cd terraform/environments/management

cp backend.hcl.example backend.hcl
# backend.hcl を編集（Step 1 の outputs から値を確認）

terraform init -backend-config=backend.hcl
terraform plan
```

### Step 3: AWS Organizations を有効化する（コンソール操作）

Organizations の新規有効化は Terraform ではなく **AWSコンソールで先に実施** し、その後 Terraform にインポートする:

```bash
# コンソールで Organizations 有効化後に実行
terraform import module.organizations.aws_organizations_organization.this <organization-id>
```

### Step 4: 残りのリソースをデプロイする

```bash
terraform plan
terraform apply
```

---

## よく使うコマンド

```bash
terraform fmt -recursive   # フォーマット
terraform validate         # 構文チェック
terraform plan             # 変更確認（必ず apply 前に実行）
terraform apply            # 適用
```
