resource "random_password" "authentik_secretkey" {
  length  = 64
  upper   = true
  lower   = true
  numeric = true
  special = false
}
