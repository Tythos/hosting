resource "digitalocean_volume" "dovolume" {
  region                  = var.DO_REGION
  name                    = "dovolume"
  size                    = 100
  initial_filesystem_type = "ext4"
  description             = "Persistent storage for server configuration and data"
}
