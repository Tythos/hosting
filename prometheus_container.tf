resource "docker_container" "prometheus_container" {
  image = docker_image.prometheus_image.image_id
  name  = "prometheus_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  group_add = [
    "992"
  ]

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    "--web.console.libraries=/etc/prometheus/console_libraries",
    "--web.console.templates=/etc/prometheus/consoles"
  ]

  volumes {
    host_path      = abspath("./prometheus-config.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/prometheus/data"
    container_path = "/prometheus"
  }
}
