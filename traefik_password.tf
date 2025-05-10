resource "random_password" "traefik_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = true
}
