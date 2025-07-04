resource "docker_container" "loki_container" {
  image   = docker_image.loki_image.image_id
  name    = "loki_container"
  logs    = true
  command = ["-config.file=/etc/loki/local-config.yaml"]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = abspath("./loki-config.yml")
    container_path = "/etc/loki/local-config.yaml"
    read_only      = true
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/loki"
    container_path = "/tmp/loki"
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/loki-data"
    container_path = "/loki/data"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
