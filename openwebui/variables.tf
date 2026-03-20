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

variable "OPENWEBUI_OAUTH_CLIENT_ID" {
  type        = string
  description = "OAuth2 client ID from Authentik (Open WebUI application)"
}

variable "OPENWEBUI_OAUTH_CLIENT_SECRET" {
  type        = string
  description = "OAuth2 client secret from Authentik (Open WebUI application)"
  sensitive   = true
}

variable "OPENWEBUI_AUTHENTIK_PROVIDER_SLUG" {
  type        = string
  description = "Authentik OIDC slug for the Open WebUI provider"
}
