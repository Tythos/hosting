resource "docker_container" "resume_container" {
  image      = docker_image.resume_image.image_id
  name       = "resume_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
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
