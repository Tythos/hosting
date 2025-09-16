# resource "docker_container" "n8n_container" {
#   image = docker_image.n8n_image.image_id
#   name  = "n8n_container"

#   env = [
#     "N8N_ENCRYPTION_KEY=${var.N8N_ENCRYPTION_KEY}",
#     "N8N_HOST=n8n.${var.HOST_NAME}",
#     "N8N_PORT=5678",
#     "N8N_PROTOCOL=http",
#     "WEBHOOK_URL=https://n8n.${var.HOST_NAME}",
#     "GENERIC_TIMEZONE=UTC",
#     "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true",
#     "N8N_RUNNERS_ENABLED=true",
#     "DB_TYPE=sqlite",
#     "DB_SQLITE_VACUUM_ON_STARTUP=true"
#   ]

#   networks_advanced {
#     name = var.HOSTING_NETWORK_NAME
#   }

#   ports {
#     internal = 5678
#   }

#   labels {
#     label = "traefik.http.routers.n8n.rule"
#     value = "Host(`n8n.${var.HOST_NAME}`)"
#   }

#   labels {
#     label = "traefik.http.routers.n8n.tls"
#     value = "true"
#   }

#   labels {
#     label = "traefik.http.routers.n8n.tls.certresolver"
#     value = "letsencrypt"
#   }

#   labels {
#     label = "traefik.http.routers.n8n.entrypoints"
#     value = "websecure"
#   }

#   labels {
#     label = "traefik.http.services.n8n.loadbalancer.server.port"
#     value = "5678"
#   }

#     volumes {
#       host_path      = var.STATE_PATH
#       container_path = "/home/node/.n8n"
#     }
# }
