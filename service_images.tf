resource "docker_image" "service_images" {
  for_each = var.services
  name     = each.value.image
}
