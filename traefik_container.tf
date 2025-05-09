resource "docker_container" "traefik_container" {
  name  = "traefik_container"
  image = docker_image.traefik_image.image_id
  command = [
    "--api.insecure=true",
    "--providers.docker",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--accesslog=true",
    "--log.level=INFO",
    "--metrics.prometheus=true",
    "--metrics.prometheus.addentrypointslabels=true",
    "--metrics.prometheus.addserviceslabels=true",
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

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/etc/letsencrypt"
    container_path = "/etc/letsencrypt"
  }
}
