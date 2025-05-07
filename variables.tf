variable "ACME_EMAIL" {
  type        = string
  description = "The email address to use for the ACME challenge"
}

variable "HOST_DOMAIN" {
  type        = string
  description = "The domain name to reference in the Traefik configuration"
}

# the following is a dynamic variable that generates a service map that will be utilized/consumed by the traefik configuration

variable "services" {
  description = "Map of services to create"
  type = map(object({
    image     = string
    port      = number
    subdomain = optional(string)
    volumes = optional(list(object({
      host_path      = string
      container_path = string
      read_only      = optional(bool)
    })))
    env     = optional(map(string))
    command = optional(list(string))
  }))
  default = {}
}
