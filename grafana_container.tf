resource "docker_container" "grafana_container" {
  image = docker_image.grafana_image.image_id
  name  = "grafana_container"
  env   = ["GF_SECURITY_ADMIN_PASSWORD=${random_password.admin_password.result}"]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = abspath("${path.root}/grafana-provisioning/datasources")
    container_path = "/etc/grafana/provisioning/datasources"
    read_only      = true
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
