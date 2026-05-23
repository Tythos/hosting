resource "docker_container" "spain_container" {
  image = docker_image.spain_image.name
  name  = "spain_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.http.routers.spain.rule"
    value = "Host(`spain.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.spain.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.spain.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.spain.entrypoints"
    value = "websecure"
  }
}
