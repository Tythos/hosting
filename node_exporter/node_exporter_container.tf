resource "docker_container" "node_exporter_container" {
  name  = "node_exporter_container"
  image = docker_image.node_exporter_image.image_id

  command = [
    "--path.rootfs=/host"
  ]

  pid_mode = "host"
  restart  = "unless-stopped"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = "/"
    container_path = "/host"
    read_only      = true
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "9100"
  }

  labels {
    label = "prometheus.job"
    value = "node-exporter"
  }
}
