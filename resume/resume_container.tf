resource "docker_container" "resume_container" {
  image = docker_image.nginx_image.image_id
  name  = "resume_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  labels {
    label = "traefik.http.routers.resume.rule"
    value = "Host(`resume.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.resume.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.resume.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.resume.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.RESUME_MOUNT
    container_path = "/usr/share/nginx/html"
  }
}
