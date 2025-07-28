resource "docker_container" "promtail_container" {
  name    = "promtail_container"
  image   = docker_image.promtail_image.image_id
  command = ["-config.file=/etc/promtail/promtail-config.yml"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/promtail-config.yml")
    container_path = "/etc/promtail/promtail-config.yml"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/var/log"
    container_path = "/var/log"
    read_only      = true
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
