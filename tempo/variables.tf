variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "The name of the hosting network"
}

variable "STATE_PATH" {
  type        = string
  description = "Path where monitoring data will be stored"
}

variable "LOKI_URL" {
  type        = string
  description = "POST address of logging endpoint"
}
