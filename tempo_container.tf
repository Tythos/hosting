resource "docker_container" "tempo_container" {
  name    = "tempo_container"
  image   = docker_image.tempo_image.image_id
  command = ["-config.file=/etc/tempo/tempo.yml"]
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = abspath("${path.root}/tempo-config.yml")
    container_path = "/etc/tempo/tempo.yml"
    read_only      = true
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/tempo/data"
    container_path = "/etc/tempo/data"
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/tempo/wal"
    container_path = "/etc/tempo/wal"
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/tempo/generator"
    container_path = "/etc/tempo/generator"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "3200"
  }

  labels {
    label = "prometheus.job"
    value = "tempo"
  }

  healthcheck {
    test         = ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3200/ready"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "30s"
  }
}
