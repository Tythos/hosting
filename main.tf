module "adminer" {
  source               = "./adminer"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  POSTGRES_HOST        = module.postgres.CONSUMER_CREDENTIALS["adminer"].host
  POSTGRES_USER        = module.postgres.CONSUMER_CREDENTIALS["adminer"].username
  POSTGRES_PASSWORD    = module.postgres.CONSUMER_CREDENTIALS["adminer"].password
  POSTGRES_DATABASE    = module.postgres.CONSUMER_CREDENTIALS["adminer"].database
}

module "aero" {
  source               = "./aero"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/aero"
}

module "auth" {
  source               = "./auth"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/auth"
  POSTGRES_HOST        = module.postgres.CONSUMER_CREDENTIALS["auth"].host
  POSTGRES_USER        = module.postgres.CONSUMER_CREDENTIALS["auth"].username
  POSTGRES_PASSWORD    = module.postgres.CONSUMER_CREDENTIALS["auth"].password
  POSTGRES_DATABASE    = module.postgres.CONSUMER_CREDENTIALS["auth"].database
}

module "cc" {
  source               = "./cc"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/cc"
}

module "easton" {
  source               = "./easton"
  HOST_NAME            = var.HOST_NAME
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  STATE_PATH           = "${var.MOUNTED_VOLUME}/easton"
}

module "flask" {
  source                = "./flask"
  HOSTING_NETWORK_NAME  = docker_network.hosting_network.name
  HOST_NAME             = var.HOST_NAME
  LOKI_URL              = module.loki.LOKI_URL
  RESEND_API_KEY        = var.RESEND_API_KEY
  TEMPO_ENDPOINT        = module.tempo.TEMPO_ENDPOINT
  AUTOMATION_EMAIL_USER = var.AUTOMATION_EMAIL_USER
}

module "grafana" {
  source               = "./grafana"
  ADMIN_PASSWORD       = random_password.admin_password.result
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/grafana"
}

module "horsemen" {
  source               = "./horsemen"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  ACTUAL_PASSWORD      = var.ACTUAL_PASSWORD
  ACTUAL_BUDGET        = var.ACTUAL_BUDGET
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

module "mailman" {
  source                = "./mailman"
  CF_ACCOUNT_ID         = var.CF_ACCOUNT_ID
  CF_API_KEY            = var.CF_API_KEY
  CF_ZONE_ID            = var.CF_ZONE_ID
  ACME_EMAIL            = var.ACME_EMAIL
  HOST_NAME             = var.HOST_NAME
  AUTOMATION_EMAIL_USER = var.AUTOMATION_EMAIL_USER
}

module "minecraft" {
  source               = "./minecraft"
  STATE_PATH           = "${var.MOUNTED_VOLUME}/minecraft"
  HOST_NAME            = var.HOST_NAME
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  LOKI_URL             = module.loki.LOKI_URL
}

module "node_exporter" {
  source               = "./node_exporter"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
}

module "postgres" {
  source               = "./postgres"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/postgres"
  LOKI_URL             = module.loki.LOKI_URL
  CONSUMERS            = var.POSTGRES_CONSUMERS
}

module "prometheus" {
  source               = "./prometheus"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/observability/prometheus"
}

module "redis" {
  source               = "./redis"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/redis"
  LOKI_URL             = module.loki.LOKI_URL
}

module "resume" {
  source               = "./resume"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  RESUME_MOUNT         = "${var.MOUNTED_VOLUME}/resume"
  LOKI_URL             = module.loki.LOKI_URL
}

module "seafile" {
  source               = "./seafile"
  HOSTING_NETWORK_NAME = docker_network.hosting_network.name
  HOST_NAME            = var.HOST_NAME
  STATE_PATH           = "${var.MOUNTED_VOLUME}/seafile"
  ACME_EMAIL           = var.ACME_EMAIL
  ADMIN_PASSWORD       = random_password.admin_password.result
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
