variable "ACME_EMAIL" {
  type        = string
  description = "The email address to use for the ACME challenge"
}

variable "HOST_DOMAIN" {
  type        = string
  description = "The domain name to reference in the Traefik configuration"
}
