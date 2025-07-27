resource "docker_container" "node_exporter_container" {
  name  = "node_exporter_container"
  image = docker_image.node_exporter_image.image_id

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }
}
