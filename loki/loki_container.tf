resource "docker_container" "loki_container" {
  name    = "loki_container"
  image   = docker_image.loki_image.image_id
  command = ["-config.file=/etc/loki/loki-config.yml"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/loki-config.yml")
    container_path = "/etc/loki/loki-config.yml"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }

  ports {
    internal = 3100
    external = 3100
    ip       = "127.0.0.1"
  }
}
