resource "digitalocean_project" "doproject" {
  name        = "hostinginfra"
  description = "Namespace for encapsulation of cloud resources"
  purpose     = "Demonstration"
  environment = "Development"

  resources = [
    digitalocean_domain.dodomain.urn,
    digitalocean_droplet.dodroplet.urn,
    digitalocean_volume.dovolume.urn
  ]
}
