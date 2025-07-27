resource "docker_container" "loki_container" {
  image   = docker_image.loki_image.image_id
  name    = "loki_container"
  logs    = true
  command = ["-config.file=/etc/loki/local-config.yaml"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/loki-config.yml")
    container_path = "/etc/loki/local-config.yaml"
    read_only      = true
  }

  volumes {
    host_path      = "${var.STATE_PATH}/loki-data"
    container_path = "/loki/data"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/tmp-loki"
    container_path = "/tmp/loki"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
