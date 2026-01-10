variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "STATE_PATH" {
  type        = string
  description = "Path where Forgejo data will be stored"
}

variable "LOKI_URL" {
  type        = string
  description = "POST address of logging endpoint"
}

variable "POSTGRES_HOST" {
  type        = string
  description = "Hostname of the PostgreSQL container"
}

variable "POSTGRES_PASSWORD" {
  type        = string
  description = "Password for PostgreSQL connection"
  sensitive   = true
}

variable "ADMIN_PASSWORD" {
  type        = string
  description = "Initial admin password for Forgejo"
  sensitive   = true
}
