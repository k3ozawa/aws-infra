# -------------------------------------------------------------------
# AWS Organizations
# -------------------------------------------------------------------
module "organizations" {
  source = "../../modules/organizations"

  dev_account_email  = var.dev_account_email
  prod_account_email = var.prod_account_email
}

# -------------------------------------------------------------------
# IAM Identity Center (SSO)
# -------------------------------------------------------------------
module "iam_identity_center" {
  source = "../../modules/iam-identity-center"

  depends_on = [module.organizations]
}

# -------------------------------------------------------------------
# CloudTrail（組織レベル）
# -------------------------------------------------------------------
module "cloudtrail" {
  source = "../../modules/cloudtrail"

  aws_region = var.aws_region

  depends_on = [module.organizations]
}
