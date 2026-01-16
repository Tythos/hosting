resource "random_password" "forgejoioauthclient_randompassword" {
  length  = 64
  upper   = true
  lower   = true
  numeric = true
  special = false
}
