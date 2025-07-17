variable "ADMIN_PASSWORD" {
  type        = string
  description = "Credential used to control dashboard acces"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}
