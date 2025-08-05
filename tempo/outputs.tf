output "TEMPO_ENDPOINT" {
  value = "http://${docker_container.tempo_container.name}:${docker_container.tempo_container.ports[0].internal}"
}
