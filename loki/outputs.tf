output "LOKI_URL" {
  value = "http://localhost:3100/loki/api/v1/push"
}

output "LOKI_PLUGIN" {
  value = docker_plugin.loki_docker_plugin
}
