resource "docker_container" "postgres_container" {
  image      = docker_image.postgres_image.image_id
  name       = "postgres_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=${random_password.postgres_password.result}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 5432
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/lib/postgresql/data"
  }
}
