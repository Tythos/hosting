resource "docker_container" "tempo_container" {
  name    = "tempo_container"
  image   = docker_image.tempo_image.image_id
  command = ["--config.file=/etc/tempo/tempo-config.yml"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 4318
  }

  volumes {
    host_path      = abspath("${path.module}/tempo-config.yml")
    container_path = "/etc/tempo/tempo-config.yml"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/tempo/traces"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
