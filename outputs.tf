output "ADMIN_PASSWORD" {
  value     = random_password.admin_password.result
  sensitive = true
}

output "TEMPO_ENDPOINT" {
  value = module.tempo.TEMPO_ENDPOINT
}

output "POSTGRES_PASSWORD" {
  value     = module.postgres.POSTGRES_PASSWORD
  sensitive = true
}
