resource "docker_container" "grafana_container" {
  image = docker_image.grafana_image.image_id
  name  = "grafana_container"
  env   = ["GF_SECURITY_ADMIN_PASSWORD=${var.ADMIN_PASSWORD}"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = var.STATE_PATH
    container_path = "/var/lib/grafana"
  }

  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`grafana.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.grafana.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.grafana.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }
}
