resource "docker_container" "alertmanager_container" {
  image = docker_image.alertmanager_image.image_id
  name  = "alertmanager_container"

  command = [
    "--config.file=/etc/alertmanager/alertmanager.yml",
    "--storage.path=/alertmanager"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = abspath("${path.module}/alertmanager-config.yml")
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }

  volumes {
    host_path      = "${var.STATE_PATH}"
    container_path = "/alertmanager"
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
} 
