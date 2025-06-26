resource "docker_image" "smogwarts_exporter_image" {
  name = "nginx/nginx-prometheus-exporter:1.1.0"
}
