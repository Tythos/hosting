# Generate a secret key for authentik
resource "random_password" "authentik_secret_key" {
  length  = 50
  upper   = true
  lower   = true
  numeric = true
  special = false
}
