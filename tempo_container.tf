resource "docker_container" "tempo_container" {
  name  = "tempo_container"
  image = docker_image.tempo_image.image_id

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

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.tempo.rule"
    value = "Host(`tempo.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.tempo.service"
    value = "tempo"
  }

  labels {
    label = "traefik.http.services.tempo.loadbalancer.server.port"
    value = "3200"
  }

  command = ["-config.file=/etc/tempo/tempo.yml"]

  healthcheck {
    test     = ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3200/ready"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }
}
