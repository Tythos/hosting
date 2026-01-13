resource "docker_container" "authentik_server_container" {
  image = docker_image.authentik_image.image_id
  name  = "authentik_server_container"

  env = [
    "AUTHENTIK_POSTGRESQL__HOST=${var.POSTGRES_HOSTNAME}",
    "AUTHENTIK_POSTGRESQL__NAME=auth",
    "AUTHENTIK_POSTGRESQL__USER=auth",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.POSTGRES_PASSWORD}",
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secretkey.result}",
  ]

  command = ["server"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 9000
  }

  ports {
    internal = 9443
  }

  labels {
    label = "traefik.http.routers.auth.rule"
    value = "Host(`auth.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.auth.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.auth.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.auth.entrypoints"
    value = "websecure"
  }

  volumes {
    container_path = "/media"
    host_path      = "${var.STATE_PATH}/media"
  }

  volumes {
    container_path = "/templates"
    host_path      = "${var.STATE_PATH}/custom-templates"
  }
}
