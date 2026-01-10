resource "docker_container" "authentik_server" {
  image      = docker_image.authentik_image.image_id
  name       = "authentik_server"
  command    = ["server"]
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  env = [
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secret_key.result}",
    "AUTHENTIK_REDIS__HOST=${var.REDIS_HOST}",
    "AUTHENTIK_POSTGRESQL__HOST=${var.POSTGRES_HOST}",
    "AUTHENTIK_POSTGRESQL__NAME=authentik",
    "AUTHENTIK_POSTGRESQL__USER=postgres",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.POSTGRES_PASSWORD}",
    "AUTHENTIK_BOOTSTRAP_PASSWORD=${var.ADMIN_PASSWORD}",
    "AUTHENTIK_BOOTSTRAP_EMAIL=${var.ACME_EMAIL}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 9000
  }

  volumes {
    host_path      = "${var.STATE_PATH}/media"
    container_path = "/media"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/templates"
    container_path = "/templates"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.authentik.rule"
    value = "Host(`auth.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.authentik.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.authentik.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.authentik.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.authentik.loadbalancer.server.port"
    value = "9000"
  }

  depends_on = [docker_container.authentik_worker]
}
