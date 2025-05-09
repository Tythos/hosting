resource "docker_container" "traefik_container" {
  name  = "traefik_container"
  image = docker_image.traefik_image.image_id
  command = [
    "--api.insecure=true",
    "--providers.docker"
  ]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}
