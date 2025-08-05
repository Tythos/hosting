variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "LOKI_URL" {
  type        = string
  description = "URL of the Loki instance to send logs to"
}

variable "RESEND_API_KEY" {
  type        = string
  description = "The API key to use for Resend email sending"
}

variable "TEMPO_ENDPOINT" {
  type        = string
  description = "The endpoint of the Tempo instance to send traces to"
}
