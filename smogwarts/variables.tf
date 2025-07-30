variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "SMOGWARTS_MOUNT" {
  type        = string
  description = "Path to static Smogwarts content"
}

variable "LOKI_URL" {
  type        = string
  description = "POST address of logging endpoint"
}
