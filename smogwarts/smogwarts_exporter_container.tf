resource "docker_container" "smogwarts_exporter_container" {
  name  = "smogwarts_exporter_container"
  image = docker_image.smogwarts_exporter_image.image_id

  networks_advanced {
    name = docker_network.hosting_network.name
  }

  command = [
    "-nginx.scrape-uri=http://smogwarts_container:9118/stub_status"
  ]

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.job"
    value = "smogwarts"
  }

  labels {
    label = "prometheus.port"
    value = "9113"
  }

  depends_on = [
    docker_container.smogwarts_container
  ]
}
