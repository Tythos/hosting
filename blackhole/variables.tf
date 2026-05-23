variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "LOKI_URL" {
  type        = string
  description = "POST address of logging endpoint"
}
