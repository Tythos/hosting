resource "docker_container" "blackhole_container" {
  image      = docker_image.blackhole_image.image_id
  name       = "blackhole_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  command = [
    "/bin/sh", "-c",
    "echo 'server { listen 80 default_server; server_name _; return 403; }' > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  # Register as a Traefik service so blocking routers can reference it.
  # No router label: Traefik will NOT auto-expose this to public ingress.
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.services.blackhole.loadbalancer.server.port"
    value = "80"
  }
}
