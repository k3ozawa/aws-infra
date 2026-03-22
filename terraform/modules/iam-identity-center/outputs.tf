output "sso_instance_arn" {
  description = "IAM Identity Center インスタンス ARN"
  value       = local.sso_instance_arn
}

output "administrator_permission_set_arn" {
  description = "AdministratorAccess Permission Set の ARN"
  value       = aws_ssoadmin_permission_set.administrator.arn
}
