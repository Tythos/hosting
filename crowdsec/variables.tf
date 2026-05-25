variable "HOSTING_NETWORK_NAME" {
  type        = string
  description = "Name of internal Docker network used for routing"
}

variable "STATE_PATH" {
  type        = string
  description = "Base path for persistent CrowdSec state (config, data, DB)"
}

variable "TRAEFIK_LOG_PATH" {
  type        = string
  description = "Host path to directory containing Traefik HTTP access logs for CrowdSec acquisition"
}
