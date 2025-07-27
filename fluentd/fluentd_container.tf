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
    host_path      = "${var.STATE_PATH}/logs"
    container_path = "/var/log/fluentd"
  }

  env = [
    "INFLUXDB_TOKEN=${var.INFLUXDB_TOKEN}",
    "INFLUXDB_ORG=${var.INFLUXDB_ORG}",
    "INFLUXDB_BUCKET=${var.INFLUXDB_BUCKET}"
  ]

  labels {
    label = "traefik.enable"
    value = "false"
  }
} 