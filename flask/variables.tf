variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "LOG_DRIVER" {
  type        = string
  description = "Name of the Docker plugin to use for logging"
}

variable "LOKI_URL" {
  type        = string
  description = "URL of the Loki instance to send logs to"
}

variable "LOKI_PLUGIN" {
  type        = any
  description = "The Loki Docker plugin resource to depend on"
}
