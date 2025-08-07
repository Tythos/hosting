resource "random_password" "postgres_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
