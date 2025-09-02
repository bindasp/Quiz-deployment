output "rds_secret_id" {
  description = "ID of the RDS password secret in Secrets Manager"
  value       = aws_secretsmanager_secret.rds_secret.id
}

output "rds_password" {
  description = "Generated RDS password"
  value       = data.aws_secretsmanager_random_password.rds_password.random_password
  sensitive   = true
}

output "argocd_password" {
  description = "Generated argocd password"
  value       = data.aws_secretsmanager_random_password.argocd_password.random_password
  sensitive   = true
}
