
resource "docker_container" "vector_container" {
  image   = docker_image.vector_image.image_id
  name    = "vector_container"
  logs    = true
  command = ["--config", "/etc/vector/vector.yml"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/vector-config.yml")
    container_path = "/etc/vector/vector.yml"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = "${var.STATE_PATH}/logs"
    container_path = "/var/log/vector"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
