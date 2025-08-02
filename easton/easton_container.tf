resource "docker_container" "easton_container" {
  image = docker_image.easton_image.image_id
  name  = "easton_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.easton.rule"
    value = "Host(`easton.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.easton.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.easton.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.easton.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/usr/share/nginx/html"
  }
}
