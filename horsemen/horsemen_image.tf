resource "docker_image" "horsemen_image" {
  name         = "horsemen_image:latest"
  keep_locally = true

  build {
    context = "${path.module}/horsemen_image"
  }
}
