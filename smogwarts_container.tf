resource "docker_container" "smogwarts_container" {
  image = docker_image.nginx_image.image_id
  name  = "smogwarts_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  ports {
    internal = 9118
  }

  labels {
    label = "traefik.http.routers.smogwarts.rule"
    value = "Host(`smogwarts.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.smogwarts.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.smogwarts.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.smogwarts.entrypoints"
    value = "websecure"
  }

  volumes {
    host_path      = var.SMOGWARTS_MOUNT
    container_path = "/usr/share/nginx/html"
  }

  volumes {
    host_path      = abspath("${path.root}/smogwarts-nginx-metrics.conf")
    container_path = "/etc/nginx/conf.d/metrics.conf"
    read_only      = true
  }
}
