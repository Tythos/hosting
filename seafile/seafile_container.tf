resource "docker_container" "seafile_container" {
  image = docker_image.seafile_image.image_id
  name  = "seafile_container"

  env = [
    "DB_HOST=${docker_container.mysql_container.name}",
    "DB_ROOT_PASSWD=${random_password.db_password.result}",
    "SEAFILE_ADMIN_EMAIL=${var.ACME_EMAIL}",
    "SEAFILE_ADMIN_PASSWORD=${var.ADMIN_PASSWORD}",
    "SEAFILE_SERVER_LETSENCRYPT=false",
    "SEAFILE_SERVER_HOSTNAME=seafile.${var.HOST_NAME}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
  }

  # web interface

  labels {
    label = "traefik.http.routers.seafile.rule"
    value = "Host(`seafile.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.seafile.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.seafile-web.entrypoints"
    value = "websecure"
  }

  #   labels {
  #     label = "traefik.http.middlewares.seafile.forwardedheaders.trustedips"
  #     value = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  #   }

  #   labels {
  #     label = "traefik.http.middlewares.seafile-headers.headers.customrequestheaders.X-Forwarded-Proto"
  #     value = "https"
  #   }

  #   labels {
  #     label = "traefik.http.routers.seafile.middlewares"
  #     value = "seafile-headers"
  #   }

  # persistent storage

  volumes {
    host_path      = "${var.STATE_PATH}/data"
    container_path = "/shared"
  }
}
