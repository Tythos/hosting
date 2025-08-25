resource "docker_image" "horsemen_image" {
  name         = "horsemen_image:latest"
  keep_locally = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "horsemen_image/**") : filesha1("${path.module}/${f}")]))
  }

  build {
    context = "${path.module}/horsemen_image"
  }
}
