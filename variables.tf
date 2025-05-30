variable "HOST_NAME" {
  type        = string
  description = "The hostname of the server, primarily used for subdomain construction and TLS"
}

variable "ACME_EMAIL" {
  type        = string
  description = "The email address to use for ACME certificate requests"
}

variable "LETSENCRYPT_ORIGIN" {
  type        = string
  description = "The origin to use for ACME certificate requests; defaults to staging, change to production when ready"
}

variable "CF_API_KEY" {
  type        = string
  description = "The API key to use for Cloudflare DNS updates"
}

variable "CF_DNS_API_TOKEN" {
  type        = string
  description = "The DNS API token to use for Cloudflare DNS updates"
}

variable "SMOGWARTS_MOUNT" {
  type        = string
  description = "Static content path for Smogwarts service"
}

variable "RESUME_MOUNT" {
  type        = string
  description = "Static content path for resume service"
}

variable "MONITORING_MOUNT" {
  type        = string
  description = "Path where metrics, logs, and events from Loki will be cached/stored"
}
