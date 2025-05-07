resource "docker_container" "service_containers" {
  for_each = var.services
  name     = each.key
  image    = docker_image.service_images[each.key].image_id
  restart  = "unless-stopped"

  # Connect to the web network
  networks_advanced {
    name = docker_network.web_network.name
  }

  # Add volumes if specified
  dynamic "volumes" {
    for_each = each.value.volumes != null ? each.value.volumes : []
    content {
      host_path      = volumes.value.host_path
      container_path = volumes.value.container_path
      read_only      = lookup(volumes.value, "read_only", null)
    }
  }

  # Add environment variables if specified
#   dynamic "env" {
#     for_each = each.value.env != null ? each.value.env : {}
#     content {
#       key   = env.key
#       value = env.value
#     }
#   }

  # Add command if specified
  command = each.value.command

  # Traefik labels for routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${each.key}.rule"
    value = "Host(`${lookup(each.value, "subdomain", each.key)}.${var.HOST_DOMAIN}`)"
  }

  labels {
    label = "traefik.http.routers.${each.key}.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.${each.key}.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.${each.key}.loadbalancer.server.port"
    value = tostring(each.value.port)
  }
}
