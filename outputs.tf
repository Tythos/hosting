output "TRAEFIK_PASSWORD" {
  value     = random_password.traefik_password.result
  sensitive = true
}
