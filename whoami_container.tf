resource "docker_container" "whooami_container" {
  image = docker_image.whoami_image.image_id
  name  = "whoami_container"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  labels {
    label = "traefik.http.routers.whoami.rule"
    value = "Host(`whoami.tythos.io`)"
  }
}
