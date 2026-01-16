resource "random_password" "forgejointernaltoken_randompassword" {
  length  = 64
  upper   = true
  lower   = true
  numeric = true
  special = false
}
