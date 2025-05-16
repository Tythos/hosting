resource "random_password" "admin_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = true
}
