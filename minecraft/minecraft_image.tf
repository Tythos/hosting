resource "docker_image" "minecraft_image" {
  name         = "minecraft_image:latest"
  keep_locally = true

  build {
    context = "${path.module}/minecraft_image"
    build_args = {
      "SERVER_JAR_URL" = "https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar"
    }
  }
}
