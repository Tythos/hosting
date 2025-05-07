resource "docker_container" "nginx_container" {
  name    = "nginx-test"
  image   = docker_image.nginx_image.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.web_network.name
  }

  volumes {
    host_path      = abspath("${path.module}/nginx-content")
    container_path = "/usr/share/nginx/html"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.nginx-test.rule"
    value = "Host(`test.${var.HOST_DOMAIN}`)"
  }

  labels {
    label = "traefik.http.routers.nginx-test.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.nginx-test.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.nginx-test.loadbalancer.server.port"
    value = "80"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/nginx-content && echo '<html><body><h1>Traefik Test</h1><p>If you see this, your Traefik setup is working!</p></body></html>' > ${path.module}/nginx-content/index.html"
  }
}
