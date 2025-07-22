resource "docker_container" "events_container" {
  image   = docker_image.events_image.image_id
  name    = "events_container"
  restart = "always"

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  labels {
    label = "loki_job_name"
    value = "docker-events"
  }
}
