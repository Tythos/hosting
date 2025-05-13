resource "docker_container" "otel_container" {
  image = docker_image.otel_image.image_id
  name  = "otel_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  labels {
    label = "traefik.http.routers.otel.rule"
    value = "Host(`otel.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.otel.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.otel.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.otel.entrypoints"
    value = "websecure"
  }
}
