variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "HOST_NAME" {
  type        = string
  description = "Concatenated to subdomain to construct FQDN used in routing rules and TLS signing"
}

variable "STATE_PATH" {
  type        = string
  description = "Base path where Open WebUI persistence data is stored"
}

variable "N8N_ENCRYPTION_KEY" {
  type        = string
  description = "Encryption key for n8n data (should be a 32-character random string)"
  sensitive   = true
}
