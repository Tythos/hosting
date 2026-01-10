resource "random_password" "forgejo_secret_key" {
  length  = 64
  special = false
}

resource "random_password" "forgejo_internal_token" {
  length  = 106
  special = false
}
