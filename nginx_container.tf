resource "docker_container" "nginx_container" {
  image = docker_image.nginx_image.image_id
  name  = "nginx_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  labels {
    label = "traefik.http.routers.nginx.rule"
    value = "Host(`nginx.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.nginx.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.nginx.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.nginx.entrypoints"
    value = "websecure"
  }
}
