terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Identity Center (SSO) は Organizations 有効化後に自動で有効化される。
# このモジュールでは Permission Set と Group Assignment を管理する。

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

# -------------------------------------------------------------------
# Permission Set: AdministratorAccess（管理者用）
# -------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "AdministratorAccess"
  description      = "Administrator access for all resources"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
