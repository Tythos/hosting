resource "docker_container" "tempo_container" {
  name    = "tempo_container"
  image   = docker_image.tempo_image.image_id
  command = ["-config.file=/etc/tempo/tempo.yml"]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = abspath("${path.root}/tempo-config.yml")
    container_path = "/etc/tempo/tempo.yml"
    read_only      = true
  }

  volumes {
    host_path      = "${var.MONITORING_MOUNT}/tempo/data"
    container_path = "/etc/tempo/data"
  }
}
