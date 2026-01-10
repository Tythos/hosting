resource "docker_container" "traefik_container" {
  name  = "traefik_container"
  image = docker_image.traefik_image.image_id

  command = [
    "--api.dashboard=true",
    "--providers.docker",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.ssh.address=:2222",
    "--entrypoints.minecraft.address=:25565",
    "--log.level=INFO",
    "--certificatesresolvers.letsencrypt.acme.email=${var.ACME_EMAIL}",
    "--certificatesresolvers.letsencrypt.acme.storage=/etc/letsencrypt/acme.json",
    "--certificatesresolvers.letsencrypt.acme.caserver=${var.LETSENCRYPT_ORIGIN}",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
    "--metrics.prometheus=true",
    "--metrics.prometheus.addEntryPointsLabels=true",
    "--metrics.prometheus.addRoutersLabels=true",
    "--metrics.prometheus.addServicesLabels=true",
    # "--metrics.prometheus.scrape=true",
    # "--metrics.prometheus.port=8080",
    # "--metrics.prometheus.job=traefik",
    "--metrics.addinternals"
  ]

  env = [
    "CF_API_EMAIL=${var.ACME_EMAIL}",
    "CF_API_KEY=${var.CF_API_KEY}",
    "CF_DNS_API_TOKEN=${var.CF_DNS_API_TOKEN}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 25565
    external = 25565
  }

  ports {
    internal = 2222
    external = 2222
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
    value = "admin:${var.ADMIN_PASSWORD}"
  }

  labels {
    label = "traefik.http.middlewares.redirect-main.redirectregex.regex"
    value = "^https?://(www\\.)?${var.HOST_NAME}/?(.*)"
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "8080"
  }

  labels {
    label = "prometheus.job"
    value = "traefik"
  }
}
