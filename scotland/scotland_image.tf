resource "docker_image" "scotland_image" {
  name = "scotland:latest"
  keep_locally = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "www/**") : filesha1("${path.module}/${f}")]))
  }

  build {
    context = "${path.module}"
  }
}
