resource "random_password" "db_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
