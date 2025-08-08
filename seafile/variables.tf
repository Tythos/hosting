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
  description = "Path to the state directory"
}

variable "ACME_EMAIL" {
  type        = string
  description = "Email for admin user profile"
}

variable "ADMIN_PASSWORD" {
  type        = string
  description = "Password for the Seafile admin user"
}
