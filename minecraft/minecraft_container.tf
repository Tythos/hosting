resource "docker_container" "minecraft_container" {
  image      = docker_image.minecraft_image.image_id
  name       = "minecraft_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }
  env        = []

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 25565
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.minecraft.entrypoints"
    value = "minecraft"
  }

  labels {
    label = "traefik.tcp.routers.minecraft.service"
    value = "minecraft-svc"
  }

  labels {
    label = "traefik.tcp.services.minecraft-svc.loadbalancer.server.port"
    value = "25565"
  }

  labels {
    label = "traefik.tcp.routers.minecraft.rule"
    value = "HostSNI(`*`)"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/world"
    container_path = "/minecraft/world"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/logs"
    container_path = "/minecraft/logs"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/config"
    container_path = "/minecraft/config"
  }

  volumes {
    host_path      = "${var.STATE_PATH}/plugins"
    container_path = "/minecraft/plugins"
  }
}
