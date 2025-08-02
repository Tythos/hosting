module "aero" {
  source               = "./aero"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/aero"
}

module "easton" {
  source               = "./easton"
  HOST_NAME            = var.HOST_NAME
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/easton"
}

module "flask" {
  source               = "./flask"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  LOKI_URL             = module.loki.LOKI_URL
}

module "grafana" {
  source               = "./grafana"
  ADMIN_PASSWORD       = random_password.admin_password.result
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
}

module "kifiew" {
  source               = "./kifiew"
  HOST_NAME            = var.HOST_NAME
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/kifiew"
}

module "loki" {
  source               = "./loki"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/loki"
}

module "macercy" {
  source               = "./macercy"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/macercy"
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

module "resume" {
  source               = "./resume"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  RESUME_MOUNT         = "${var.MOUNTED_VOLUME}/resume"
  LOKI_URL             = module.loki.LOKI_URL
}

module "smogwarts" {
  source               = "./smogwarts"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  SMOGWARTS_MOUNT      = "${var.MOUNTED_VOLUME}/smogwarts"
  LOKI_URL             = module.loki.LOKI_URL
}

module "tempo" {
  source               = "./tempo"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/tempo"
  LOKI_URL             = module.loki.LOKI_URL
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
  LOKI_URL             = module.loki.LOKI_URL
}
