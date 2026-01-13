resource "random_password" "adminer_db_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
