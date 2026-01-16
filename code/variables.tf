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
  description = "Path where stateful volume will be mounted"
}

variable "FORGEJO_OAUTH_CLIENT_ID" {
  type        = string
  description = "OAuth2 Client ID for Forgejo in Authentik"
}

variable "FORGEJO_OAUTH_CLIENT_SECRET" {
  type        = string
  description = "OAuth2 Client Secret for Forgejo in Authentik"
}
