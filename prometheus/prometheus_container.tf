resource "docker_container" "prometheus_container" {
  image = docker_image.prometheus_image.image_id
  name  = "prometheus_container"

  group_add = ["121"]

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    "--web.console.libraries=/etc/prometheus/console_libraries",
    "--web.console.templates=/etc/prometheus/consoles"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/prometheus-config.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/prometheus"
  }

  volumes {
    host_path      = abspath("${path.module}/alert-rules.yml")
    container_path = "/etc/prometheus/alert-rules.yml"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
