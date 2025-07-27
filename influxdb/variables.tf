variable "HOSTING_NETWORK_NAME" {
  description = "Name of the hosting network"
  type        = string
}

variable "STATE_PATH" {
  description = "Path for influxdb data"
  type        = string
}

variable "INFLUXDB_USERNAME" {
  description = "InfluxDB admin username"
  type        = string
  default     = "admin"
}

variable "INFLUXDB_PASSWORD" {
  description = "InfluxDB admin password"
  type        = string
  sensitive   = true
}

variable "INFLUXDB_ORG" {
  description = "InfluxDB organization name"
  type        = string
  default     = "myorg"
}

variable "INFLUXDB_BUCKET" {
  description = "InfluxDB bucket name for logs"
  type        = string
  default     = "docker_logs"
}

variable "INFLUXDB_TOKEN" {
  description = "InfluxDB admin token"
  type        = string
  sensitive   = true
} 