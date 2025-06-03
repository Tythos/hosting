resource "docker_image" "flask_image" {
  name         = "flask_image:latest"
  keep_locally = true

  build {
    context = "./flask_image"
  }
}
