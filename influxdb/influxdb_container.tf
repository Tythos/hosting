resource "docker_image" "influxdb_image" {
  name = "influxdb:2.7-alpine"
}

resource "docker_container" "influxdb_container" {
  image   = docker_image.influxdb_image.image_id
  name    = "influxdb_container"
  logs    = true

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = "${var.STATE_PATH}/influxdb"
    container_path = "/var/lib/influxdb2"
  }

  env = [
    "DOCKER_INFLUXDB_INIT_MODE=setup",
    "DOCKER_INFLUXDB_INIT_USERNAME=${var.INFLUXDB_USERNAME}",
    "DOCKER_INFLUXDB_INIT_PASSWORD=${var.INFLUXDB_PASSWORD}",
    "DOCKER_INFLUXDB_INIT_ORG=${var.INFLUXDB_ORG}",
    "DOCKER_INFLUXDB_INIT_BUCKET=${var.INFLUXDB_BUCKET}",
    "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${var.INFLUXDB_TOKEN}"
  ]

  ports {
    internal = 8086
    external = 8086
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
} 