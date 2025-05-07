resource "local_file" "traefik_dynamic_conf" {
  content  = file("${path.module}/config/dynamic.yml")
  filename = "${path.module}/config/dynamic.yml"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/config ${path.module}/certs"
  }
}
