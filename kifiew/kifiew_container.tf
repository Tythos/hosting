resource "docker_container" "kifiew_container" {
  image = docker_image.kifiew_image.image_id
  name  = "kifiew_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.kifiew.rule"
    value = "Host(`kifiew.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.kifiew.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.kifiew.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.kifiew.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/usr/share/nginx/html"
  }
}
