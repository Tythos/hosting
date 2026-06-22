resource "docker_image" "minecraft_image" {
  name         = "minecraft_image"
  keep_locally = true

  build {
    context = "${path.module}/minecraft_image"
    build_args = {
      "SERVER_JAR_URL" = "https://piston-data.mojang.com/v1/objects/${var.MINECRAFT_JAR_HASH}/server.jar"
    }
  }
}
