output "POSTGRES_PASSWORD" {
  value     = random_password.postgres_password.result
  sensitive = true
}

output "POSTGRES_HOSTNAME" {
  value = docker_container.postgres_container.name
}
