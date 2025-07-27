resource "random_password" "admin_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = true
}

resource "random_password" "influxdb_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = true
}

resource "random_password" "influxdb_token" {
  length  = 32
  upper   = true
  lower   = true
  numeric = true
  special = false
}
