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

variable "ACME_EMAIL" {
  type        = string
  description = "The email address to use for ACME certificate requests"
}

variable "LETSENCRYPT_ORIGIN" {
  type        = string
  description = "Origin to use for ACME certificate requests; defaults to staging, change to production when ready"
}

variable "CF_API_KEY" {
  type        = string
  description = "The API key to use for Cloudflare DNS updates"
}

variable "CF_DNS_API_TOKEN" {
  type        = string
  description = "The DNS API token to use for Cloudflare DNS updates"
}
