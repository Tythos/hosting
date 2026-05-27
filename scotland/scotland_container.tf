resource "docker_container" "scotland_container" {
  image = docker_image.scotland_image.name
  name  = "scotland_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.scotland.rule"
    value = "Host(`scotland.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.scotland.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.scotland.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.scotland.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.scotland.middlewares"
    value = "public"
  }
}
