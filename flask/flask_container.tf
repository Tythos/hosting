resource "docker_container" "flask_container" {
  image      = docker_image.flask_image.image_id
  name       = "flask_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  env = [
    "OTEL_SERVICE_NAME=flask-app",
    "OTEL_EXPORTER_OTLP_ENDPOINT=${var.TEMPO_ENDPOINT}",
    "OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf",
    "OTEL_PYTHON_LOG_CORRELATION=true",
    "OTEL_TRACES_SAMPLER=always_on",
    "OTEL_TRACES_SAMPLER_ARG=1.0",
    "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true",
    "OTEL_TRACES_EXPORTER=otlp",
    "OTEL_LOGS_EXPORTER=none",
    "OTEL_METRICS_EXPORTER=none",
    "RESEND_API_KEY=${var.RESEND_API_KEY}"
  ]

  entrypoint = [
    "opentelemetry-instrument",
    "flask", "run", "--port=80", "--host=0.0.0.0"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
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
