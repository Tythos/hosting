resource "docker_container" "authentik_container" {
  image = docker_image.authentik_image.image_id
  name  = "authentik_container"

  command = ["server"]

  env = [
    "AUTHENTIK_POSTGRESQL__HOST=${var.POSTGRES_HOST}",
    "AUTHENTIK_POSTGRESQL__USER=${var.POSTGRES_USER}",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.POSTGRES_PASSWORD}",
    "AUTHENTIK_POSTGRESQL__NAME=${var.POSTGRES_DATABASE}",
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secret_key.result}",
    "AUTHENTIK_ERROR_REPORTING__ENABLED=false"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 9000
  }

  volumes {
    host_path      = "${var.STATE_PATH}/media"
    container_path = "/media"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/templates"
    container_path = "/templates"
  }

  labels {
    label = "traefik.http.routers.authentik.rule"
    value = "Host(`auth.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.authentik.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.authentik.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.authentik.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.authentik.loadbalancer.server.port"
    value = "9000"
  }
}
