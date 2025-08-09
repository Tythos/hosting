resource "docker_container" "redis_container" {
  image      = docker_image.redis_image.image_id
  name       = "redis_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }
  env        = []

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 6379
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/data"
  }
}
