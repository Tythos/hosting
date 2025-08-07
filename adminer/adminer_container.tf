resource "docker_container" "adminer_container" {
  image = docker_image.adminer_image.image_id
  name  = "adminer_container"

  env = [
    "ADMINER_DEFAULT_SERVER=${var.POSTGRES_HOST}",
    "ADMINER_DEFAULT_USER=postgres",
    "ADMINER_DEFAULT_PASSWORD=${var.POSTGRES_PASSWORD}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 8080
  }

  labels {
    label = "traefik.http.routers.adminer.rule"
    value = "Host(`adminer.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.adminer.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.adminer.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.adminer.entrypoints"
    value = "websecure"
  }
}
