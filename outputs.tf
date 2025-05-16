output "ADMIN_PASSWORD" {
  value     = random_password.admin_password.result
  sensitive = true
}
