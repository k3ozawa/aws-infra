output "organization_id" {
  description = "AWS Organizations の組織 ID"
  value       = aws_organizations_organization.this.id
}

output "management_account_id" {
  description = "管理アカウント ID"
  value       = aws_organizations_organization.this.master_account_id
}

output "organization_arn" {
  description = "AWS Organizations の ARN"
  value       = aws_organizations_organization.this.arn
}

output "dev_account_id" {
  description = "dev アカウント ID"
  value       = aws_organizations_account.dev.id
}

output "prod_account_id" {
  description = "prod アカウント ID"
  value       = aws_organizations_account.prod.id
}
