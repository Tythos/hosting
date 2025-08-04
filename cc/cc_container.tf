resource "docker_container" "cc_container" {
  image = docker_image.cc_image.image_id
  name  = "cc_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.cc.rule"
    value = "Host(`cc.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.cc.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.cc.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.cc.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/www/html"
  }
}
