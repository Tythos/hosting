variable "HOSTING_NETWORK_NAME" {
  description = "Name of the hosting network"
  type        = string
}

variable "STATE_PATH" {
  description = "Path for fluentd state and logs"
  type        = string
}

variable "INFLUXDB_TOKEN" {
  description = "InfluxDB token for authentication"
  type        = string
  sensitive   = true
}

variable "INFLUXDB_ORG" {
  description = "InfluxDB organization name"
  type        = string
}

variable "INFLUXDB_BUCKET" {
  description = "InfluxDB bucket name for logs"
  type        = string
} 