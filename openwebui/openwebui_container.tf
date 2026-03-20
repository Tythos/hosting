resource "docker_container" "openwebui_container" {
  image = docker_image.openwebui_image.image_id
  name  = "openwebui_container"

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 8080
  }

  volumes {
    host_path      = "${var.STATE_PATH}/data"
    container_path = "/app/backend/data"
  }

  labels {
    label = "traefik.http.routers.chat.rule"
    value = "Host(`chat.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.chat.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.chat.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.chat.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.chat.service"
    value = "chat"
  }

  labels {
    label = "traefik.http.services.chat.loadbalancer.server.port"
    value = "8080"
  }
}
