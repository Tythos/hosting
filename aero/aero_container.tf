resource "docker_container" "aero_container" {
  image = docker_image.aero_image.image_id
  name  = "aero_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.aero.rule"
    value = "Host(`aero.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.aero.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.aero.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.aero.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/www/html"
  }
}
