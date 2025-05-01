resource "local_file" "traefik_dynamic_conf" {
  content  = file("${path.module}/config/dynamic.yml")
  filename = "${path.module}/config/dynamic.yml"
}
