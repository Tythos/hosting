resource "random_password" "forgejosecretkey_randompassword" {
  length  = 64
  upper   = true
  lower   = true
  numeric = true
  special = false
}
