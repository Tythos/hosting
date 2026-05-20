resource "docker_image" "spain_image" {
  name = "spain:latest"
  keep_locally = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "www/**") : filesha1("${path.module}/${f}")]))
  }

  build {
    context = "${path.module}"
  }
}
