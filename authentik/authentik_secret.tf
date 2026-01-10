resource "random_password" "authentik_secret_key" {
  length  = 50
  special = false
}
