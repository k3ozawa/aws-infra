output "state_bucket_name" {
  description = "Terraform state 用 S3 バケット名"
  value       = module.terraform_state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "Terraform state 用 S3 バケット ARN"
  value       = module.terraform_state_bucket.s3_bucket_arn
}

output "terraform_execution_role_arn" {
  description = "Terraform 実行用 IAM ロール ARN"
  value       = module.terraform_execution_role.iam_role_arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions 用 IAM ロール ARN（GitHub Secret: AWS_GITHUB_ACTIONS_ROLE_ARN に設定）"
  value       = var.github_repository != "" ? module.github_actions_role[0].iam_role_arn : null
}
