resource "random_password" "auth_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
