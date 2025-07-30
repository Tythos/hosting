resource "docker_container" "whoami_container" {
  image      = docker_image.whoami_image.image_id
  name       = "whoami_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  labels {
    label = "traefik.http.routers.whoami.rule"
    value = "Host(`whoami.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.whoami.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.whoami.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.whoami.entrypoints"
    value = "websecure"
  }
}
