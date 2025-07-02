variable "DO_TOKEN" {
  type        = string
  description = "API token for deployment of DigitalOcean resources"
}

variable "DO_REGION" {
  type        = string
  description = "DigitalOcean region into which resources will be deployed"
}

variable "DOMAIN_NAME" {
  type        = string
  description = "Managed domain name (should point to DigitalOcean NS records) used by the VM"
}
