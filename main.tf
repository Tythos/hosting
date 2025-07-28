module "flask" {
  source               = "./flask"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
}

module "grafana" {
  source               = "./grafana"
  ADMIN_PASSWORD       = random_password.admin_password.result
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
}

module "loki" {
  source               = "./loki"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/loki"
}

module "node_exporter" {
  source               = "./node_exporter"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
}

module "prometheus" {
  source               = "./prometheus"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/prometheus"
}

module "promtail" {
  source               = "./promtail"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/promtail"
}

module "resume" {
  source               = "./resume"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  RESUME_MOUNT         = "${var.MOUNTED_VOLUME}/resume"
}

module "smogwarts" {
  source               = "./smogwarts"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  SMOGWARTS_MOUNT      = "${var.MOUNTED_VOLUME}/smogwarts"
}

module "traefik" {
  source               = "./traefik"
  ADMIN_PASSWORD       = random_password.admin_password.bcrypt_hash
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  ACME_EMAIL           = var.ACME_EMAIL
  LETSENCRYPT_ORIGIN   = var.LETSENCRYPT_ORIGIN
  CF_API_KEY           = var.CF_API_KEY
  CF_DNS_API_TOKEN     = var.CF_DNS_API_TOKEN
}

module "whoami" {
  source               = "./whoami"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
}
