resource "docker_image" "events_image" {
  name         = "events_image:latest"
  keep_locally = true

  build {
    context = "./events_image"
  }
}
