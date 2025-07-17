resource "docker_image" "node_exporter_image" {
  name          = "prom/node-exporter:v1.8.2"
  keep_locally  = true
}
