resource "docker_container" "macercy_container" {
  image = docker_image.macercy_image.image_id
  name  = "macercy_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.macercy.rule"
    value = "Host(`macercy.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.macercy.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.macercy.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.macercy.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/www/html"
  }
}
