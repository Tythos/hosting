resource "docker_container" "forgejo_container" {
  image      = docker_image.forgejo_image.image_id
  name       = "forgejo_container"
  log_driver = "loki"
  log_opts   = { "loki-url" = var.LOKI_URL }

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "FORGEJO__database__DB_TYPE=postgres",
    "FORGEJO__database__HOST=${var.POSTGRES_HOST}:5432",
    "FORGEJO__database__NAME=forgejo",
    "FORGEJO__database__USER=postgres",
    "FORGEJO__database__PASSWD=${var.POSTGRES_PASSWORD}",
    "FORGEJO__server__DOMAIN=git.${var.HOST_NAME}",
    "FORGEJO__server__ROOT_URL=https://git.${var.HOST_NAME}/",
    "FORGEJO__server__SSH_DOMAIN=git.${var.HOST_NAME}",
    "FORGEJO__server__SSH_PORT=2222",
    "FORGEJO__server__SSH_LISTEN_PORT=22",
    "FORGEJO__security__SECRET_KEY=${random_password.forgejo_secret_key.result}",
    "FORGEJO__security__INTERNAL_TOKEN=${random_password.forgejo_internal_token.result}",
    "FORGEJO__security__INSTALL_LOCK=true",
    "FORGEJO__service__DISABLE_REGISTRATION=false",
    "FORGEJO__oauth2__ENABLED=true"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 3000
  }

  ports {
    internal = 22
  }

  volumes {
    host_path      = "${var.STATE_PATH}/data"
    container_path = "/data"
  }

  # HTTP router for web interface
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.forgejo.rule"
    value = "Host(`git.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.forgejo.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.forgejo.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.forgejo.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.forgejo.service"
    value = "forgejo-http"
  }

  labels {
    label = "traefik.http.services.forgejo-http.loadbalancer.server.port"
    value = "3000"
  }

  # TCP router for SSH
  labels {
    label = "traefik.tcp.routers.forgejo-ssh.entrypoints"
    value = "ssh"
  }

  labels {
    label = "traefik.tcp.routers.forgejo-ssh.rule"
    value = "HostSNI(`*`)"
  }

  labels {
    label = "traefik.tcp.routers.forgejo-ssh.service"
    value = "forgejo-ssh-svc"
  }

  labels {
    label = "traefik.tcp.services.forgejo-ssh-svc.loadbalancer.server.port"
    value = "22"
  }
}
