resource "docker_container" "trace_test_app_container" {
  name  = "trace_test_app_container"
  image = docker_image.trace_test_app_image.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  labels {
    label = "traefik.http.routers.trace-test.rule"
    value = "Host(`trace-test.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.trace-test.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.trace-test.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.trace-test.entrypoints"
    value = "websecure"
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "5000"
  }

  labels {
    label = "prometheus.job"
    value = "trace-test-app"
  }

  healthcheck {
    test         = ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5000/health"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "30s"
  }
} 