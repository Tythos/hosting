resource "docker_plugin" "loki_docker_plugin" {
  name                  = "grafana/loki-docker-driver"
  grant_all_permissions = true
  enabled               = true
  force_destroy         = true
  force_disable         = true
}
