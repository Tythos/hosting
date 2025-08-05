variable "CF_ACCOUNT_ID" {
  type        = string
  description = "The ID of the Cloudflare account"
}

variable "CF_API_KEY" {
  type        = string
  description = "The API key to use for Cloudflare DNS updates"
}

variable "CF_ZONE_ID" {
  type        = string
  description = "The ID of the Cloudflare zone (to use for email routing)"
}

variable "ACME_EMAIL" {
  type        = string
  description = "The email address to use for ACME certificate requests"
}

variable "HOST_NAME" {
  type        = string
  description = "The hostname of the server, primarily used for subdomain construction and TLS"
}

variable "AUTOMATION_EMAIL_USER" {
  type        = string
  description = "The username for the automation email account"
}
