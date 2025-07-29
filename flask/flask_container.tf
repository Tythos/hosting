resource "docker_container" "flask_container" {
  image      = docker_image.flask_image.image_id
  name       = "flask_container"
  log_driver = var.LOG_DRIVER
  depends_on = [var.LOKI_PLUGIN]
  log_opts = {
    "loki-url"         = var.LOKI_URL
    "loki-retries"     = "5"
    "loki-batch-size"  = "400"
    "loki-max-backoff" = "800ms"
    "loki-timeout"     = "1s"
    "keep-file"        = "true"
    "loki-pipeline-stages" = "[]"
    "loki-relabel-config" = "[]"
  }

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  labels {
    label = "traefik.http.routers.flask.rule"
    value = "Host(`flask.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.flask.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.flask.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.flask.entrypoints"
    value = "websecure"
  }
}
