resource "docker_container" "smogwarts_container" {
  image      = docker_image.smogwarts_image.image_id
  name       = "smogwarts_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.smogwarts.rule"
    value = "Host(`smogwarts.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.smogwarts.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.smogwarts.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.smogwarts.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.SMOGWARTS_MOUNT
    container_path = "/usr/share/nginx/html"
  }
}
