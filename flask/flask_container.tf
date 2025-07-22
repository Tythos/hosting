resource "docker_container" "flask_container" {
  image = docker_image.flask_image.image_id
  name  = "flask_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  labels {
    label = "traefik.http.routers.flask.rule"
    value = "Host(`flask.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.flask.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.flask.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.flask.entrypoints"
    value = "websecure"
  }
}
