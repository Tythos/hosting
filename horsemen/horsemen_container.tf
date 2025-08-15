resource "docker_container" "horsemen_container" {
  image = docker_image.horsemen_image.image_id
  name  = "horsemen_container"

  env = [
    "ACTUAL_PASSWORD=${var.ACTUAL_PASSWORD}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 3001
  }

  labels {
    label = "traefik.enable"
    value = "false"
  }
}
