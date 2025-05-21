resource "docker_container" "promtail_container" {
  image   = docker_image.promtail_image.image_id
  name    = "promtail_container"
  command = ["-config.file=/etc/promtail/config.yml"]

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = "/var/log"
    container_path = "/var/log"
    read_only      = true
  }

  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers"
    read_only      = true
  }

  volumes {
    host_path      = abspath("./promtail-config.yml")
    container_path = "/etc/promtail/config.yml"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
}
