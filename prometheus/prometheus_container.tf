resource "docker_container" "prometheus_container" {
  image = docker_image.prometheus_image.image_id
  name  = "prometheus_container"
  command = [
    "--config.file=/etc/prometheus/prometheus.yml"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    # NOTE: container restart required to reload configuration changes!
    host_path      = abspath("${path.module}/prometheus-config.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }

  # TODO: Add alert-rules.yml to the container to include in event reporting
  #volumes {
  #  host_path      = abspath("${path.module}/alert-rules.yml")
  #  container_path = "/etc/prometheus/alert-rules.yml"
  #}

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
