resource "docker_container" "flask_container" {
  image      = docker_image.flask_image.name
  name       = "flask_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }
  env = [
    "OTEL_SERVICE_NAME=flask-app",
    "OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo_container:4317",
    "OTEL_PYTHON_LOG_CORRELATION=true"
  ]

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

  entrypoint = [
    "opentelemetry-instrument",
    "--traces_exporter", "otlp",
    "--service_name", "flask-app",
    "python", "server.py"
  ]
}
