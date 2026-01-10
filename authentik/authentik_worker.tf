resource "docker_container" "authentik_worker" {
  image      = docker_image.authentik_image.image_id
  name       = "authentik_worker"
  command    = ["worker"]
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  env = [
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secret_key.result}",
    "AUTHENTIK_REDIS__HOST=${var.REDIS_HOST}",
    "AUTHENTIK_POSTGRESQL__HOST=${var.POSTGRES_HOST}",
    "AUTHENTIK_POSTGRESQL__NAME=authentik",
    "AUTHENTIK_POSTGRESQL__USER=postgres",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.POSTGRES_PASSWORD}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = "${var.STATE_PATH}/media"
    container_path = "/media"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/templates"
    container_path = "/templates"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/certs"
    container_path = "/certs"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
