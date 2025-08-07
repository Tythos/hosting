variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "POSTGRES_HOST" {
  type        = string
  description = "Host of the PostgreSQL server"
}

variable "POSTGRES_PASSWORD" {
  type        = string
  description = "Password of the PostgreSQL server"
}
