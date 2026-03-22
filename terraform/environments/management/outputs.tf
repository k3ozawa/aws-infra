output "organization_id" {
  description = "AWS Organizations の組織 ID"
  value       = module.organizations.organization_id
}

output "management_account_id" {
  description = "管理アカウント ID"
  value       = module.organizations.management_account_id
}
