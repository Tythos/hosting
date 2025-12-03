# resource "docker_container" "actual_container" {
#   image = docker_image.actual_image.image_id
#   name  = "actual_container"

#   networks_advanced {
#     name = var.HOSTING_NETWORK_NAME
#   }

#   ports {
#     internal = 5006
#   }

#   labels {
#     label = "traefik.http.routers.actual.rule"
#     value = "Host(`actual.${var.HOST_NAME}`)"
#   }

#   labels {
#     label = "traefik.http.routers.actual.tls"
#     value = "true"
#   }

#   labels {
#     label = "traefik.http.routers.actual.tls.certresolver"
#     value = "letsencrypt"
#   }

#   labels {
#     label = "traefik.http.routers.actual.entrypoints"
#     value = "websecure"
#   }

#   volumes {
#     host_path      = var.STATE_PATH
#     container_path = "/data"
#   }
# }
