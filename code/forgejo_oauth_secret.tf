resource "random_password" "forgejo_oauth_client_secret" {
  length  = 64
  upper   = true
  lower   = true
  numeric = true
  special = false
}
