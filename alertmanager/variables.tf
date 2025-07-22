variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "MONITORING_MOUNT" {
  type        = string
  description = "Path where monitoring data will be stored"
}
