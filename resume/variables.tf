variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "The name of the hosting network"
}

variable "HOST_NAME" {
  type        = string
  description = "The name of the host"
}

variable "RESUME_MOUNT" {
  type        = string
  description = "Path to static content mount"
}

variable "LOKI_URL" {
  type        = string
  description = "POST address of logging endpoint"
}
