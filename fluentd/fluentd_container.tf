resource "docker_image" "fluentd_image" {
  name = "fluent/fluentd:v1.16-1"
}

resource "docker_container" "fluentd_container" {
  image   = docker_image.fluentd_image.image_id
  name    = "fluentd_container"
  logs    = true

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/fluentd.conf")
    container_path = "/fluentd/etc/fluent.conf"
    read_only      = true
  }

  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers"
    read_only      = true
  }

  volumes {
    host_path      = "/var/log"
    container_path = "/var/log"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/fluentd"
    container_path = "/fluentd/log"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
} 