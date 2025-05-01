resource "docker_container" "traefik_container" {
  name    = "traefik"
  image   = docker_image.traefik_image.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.web_network.name
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
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/config")
    container_path = "/etc/traefik"
  }

  volumes {
    host_path      = abspath("${path.module}/certs")
    container_path = "/certs"
  }

  command = [
    "--api.dashboard=true",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--providers.docker.network=${docker_network.web_network.name}",
    "--providers.file.directory=/etc/traefik",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--certificatesresolvers.letsencrypt.acme.email=${var.ACME_EMAIL}",
    "--certificatesresolvers.letsencrypt.acme.storage=/certs/acme.json",
    "--certificatesresolvers.letsencrypt.acme.httpchallenge=true",
    "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web",
    "--entrypoints.web.http.redirections.entryPoint.to=websecure",
    "--entrypoints.web.http.redirections.entryPoint.scheme=https",
    "--log.level=INFO"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.traefik-dashboard.rule"
    value = "Host(`traefik.${var.HOST_DOMAIN}`)"
  }

  labels {
    label = "traefik.http.routers.traefik-dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.traefik-dashboard.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.traefik-dashboard.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.routers.traefik-dashboard.middlewares"
    value = "traefik-auth"
  }

  labels {
    label = "traefik.http.middlewares.traefik-auth.basicauth.users"
    value = "admin:${bcrypt(random_password.traefik_password.result)}"
  }

  depends_on = [
    local_file.traefik_dynamic_conf
  ]
}
