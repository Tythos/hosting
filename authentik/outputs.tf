output "AUTHENTIK_HOST" {
  value = docker_container.authentik_server.name
}

output "AUTHENTIK_URL" {
  value = "https://auth.${var.HOST_NAME}"
}
