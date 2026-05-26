resource "docker_container" "crowdsec_container" {
  name  = "crowdsec_container"
  image = docker_image.crowdsec_image.image_id

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  # Persistent configuration (auto-populated by container entrypoint on first run)
  volumes {
    host_path      = "${var.STATE_PATH}/config"
    container_path = "/etc/crowdsec"
  }

  # Persistent LAPI database and runtime data
  volumes {
    host_path      = "${var.STATE_PATH}/data"
    container_path = "/var/lib/crowdsec/data"
  }

  # Shared volume: Traefik writes HTTP access logs here, CrowdSec agent tails them
  volumes {
    host_path      = var.TRAEFIK_LOG_PATH
    container_path = "/var/log/traefik"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
