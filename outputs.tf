output "ADMIN_PASSWORD" {
  value     = module._credentials.ADMIN_PASSWORD
  sensitive = true
}

output "TEMPO_ENDPOINT" {
  value = module.tempo.TEMPO_ENDPOINT
}

output "POSTGRES_PASSWORD" {
  value     = module.postgres.POSTGRES_PASSWORD
  sensitive = true
}
