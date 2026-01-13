output "ADMIN_PASSWORD" {
  value     = random_password.admin_password.result
  sensitive = true
}

output "ADMIN_BCRYPT" {
  value     = random_password.admin_password.bcrypt_hash
  sensitive = true
}

output "ADMINER_DB_PASSWORD" {
  value     = random_password.adminer_db_password.result
  sensitive = true
}

output "AUTH_DB_PASSWORD" {
  value     = random_password.auth_password.result
  sensitive = true
}