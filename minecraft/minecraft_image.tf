resource "docker_image" "minecraft_image" {
  name         = "minecraft_image:latest"
  keep_locally = true

  build {
    context = "${path.module}/minecraft_image"
  }
}
