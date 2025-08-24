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

variable "CF_ACCOUNT_ID" {
  type        = string
  description = "The ID of the Cloudflare account"
}

variable "CF_API_KEY" {
  type        = string
  description = "The API key to use for Cloudflare DNS updates"
}

variable "CF_DNS_API_TOKEN" {
  type        = string
  description = "The DNS API token to use for Cloudflare DNS updates"
}

variable "CF_ZONE_ID" {
  type        = string
  description = "The ID of the Cloudflare zone (to use for email routing)"
}

variable "MOUNTED_VOLUME" {
  type        = string
  description = "Path where metrics, logs, and events from Loki will be cached/stored"
}

variable "RESEND_API_KEY" {
  type        = string
  description = "The API key to use for Resend email sending"
}

variable "AUTOMATION_EMAIL_USER" {
  type        = string
  description = "The username for the automation email account"
}

variable "N8N_ENCRYPTION_KEY" {
  type        = string
  description = "Encryption key for n8n data (should be a 32-character random string)"
  sensitive   = true
}

variable "ACTUAL_PASSWORD" {
  type        = string
  description = "The password for the Actual instance"
}

variable "ACTUAL_BUDGET" {
  type        = string
  description = "The UUID of the Actual budget to use"
}
