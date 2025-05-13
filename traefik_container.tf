resource "docker_container" "traefik_container" {
  name  = "traefik_container"
  image = docker_image.traefik_image.image_id

  command = [
    "--api.dashboard=true",
    "--providers.docker",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--accesslog=true",
    "--metrics.otlp=true",
    "--experimental.otlpLogs=true",
    "--log.level=INFO",
    "--log.otlp=true",
    "--log.otlp.http=true",
    "--log.otlp.http.endpoint=http://${docker_container.otel_container.name}:4318/v1/logs",
    "--tracing=true",
    "--certificatesresolvers.letsencrypt.acme.email=${var.ACME_EMAIL}",
    "--certificatesresolvers.letsencrypt.acme.storage=/etc/letsencrypt/acme.json",
    "--certificatesresolvers.letsencrypt.acme.caserver=${var.LETSENCRYPT_ORIGIN}",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
  ]

  env = [
    "CF_API_EMAIL=${var.ACME_EMAIL}",
    "CF_API_KEY=${var.CF_API_KEY}",
    "CF_DNS_API_TOKEN=${var.CF_DNS_API_TOKEN}"
  ]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/etc/letsencrypt"
    container_path = "/etc/letsencrypt"
  }

  # labels for the dashboard itself are assigned via router w/ middleware

  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = "Host(`dashboard.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "basic-auth"
  }

  labels {
    label = "traefik.http.middlewares.basic-auth.basicAuth.users"
    value = "admin:${random_password.traefik_password.bcrypt_hash}"
  }

  labels {
    label = "traefik.http.middlewares.redirect-main.redirectregex.regex"
    value = "^https?://(www\\.)?${var.HOST_NAME}/?(.*)"
  }
}
