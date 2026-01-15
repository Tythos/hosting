resource "docker_container" "forgejo_container" {
  image = docker_image.forgejo_image.image_id
  name  = "forgejo_container"
  env = [
    "GITEA__server__SSH_PORT=2222",
    "GITEA__server__ROOT_URL=https://code.${var.HOST_NAME}/",
    "GITEA__service__DISABLE_REGISTRATION=false",
    "GITEA__service__ALLOW_ONLY_EXTERNAL_REGISTRATION=false",
    "GITEA__openid__ENABLE_OPENID_SIGNIN=true",
    "GITEA__openid__ENABLE_OPENID_SIGNUP=true",
    "GITEA__oauth2_client__ENABLE_AUTO_REGISTRATION=true",
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 22
    protocol = "tcp"
  }

  ports {
    internal = 3000
  }

  labels {
    label = "traefik.http.routers.code.rule"
    value = "Host(`code.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.code.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.code.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.code.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.code.loadbalancer.server.port"
    value = "3000"
  }

  # TCP routing for SSH/Git operations
  labels {
    label = "traefik.tcp.routers.forgejo-ssh.rule"
    value = "HostSNI(`*`)"
  }

  labels {
    label = "traefik.tcp.routers.forgejo-ssh.entrypoints"
    value = "ssh"
  }

  labels {
    label = "traefik.tcp.routers.forgejo-ssh.service"
    value = "forgejo-ssh"
  }

  labels {
    label = "traefik.tcp.services.forgejo-ssh.loadbalancer.server.port"
    value = "22"
  }

  volumes {
    container_path = "/data"
    host_path      = "${var.STATE_PATH}/forgejo"
  }
}
