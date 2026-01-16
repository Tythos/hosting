resource "local_file" "forgejo_config" {
  filename        = "${path.module}/app.ini"
  file_permission = "0666"
  content = templatefile("${path.module}/app.ini.tftpl", {
    domain                  = "code.${var.HOST_NAME}"
    secret_key              = random_password.forgejoioauthclient_randompassword.result
    internal_token          = random_password.forgejointernaltoken_randompassword.result
    authentik_client_id     = var.FORGEJO_OAUTH_CLIENT_ID
    authentik_client_secret = var.FORGEJO_OAUTH_CLIENT_SECRET
    authentik_domain        = "auth.${var.HOST_NAME}"
  })
}

resource "null_resource" "forgejo_config_perms" {
  depends_on = [local_file.forgejo_config]
  triggers = {
    config = local_file.forgejo_config.content_md5
  }

  provisioner "local-exec" {
    command = "chown 1000:1000 ${abspath(local_file.forgejo_config.filename)}"
  }
}

resource "docker_container" "forgejo_container" {
  image      = docker_image.forgejo_image.image_id
  name       = "forgejo_container"
  depends_on = [local_file.forgejo_config]
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

  volumes {
    container_path = "/data/gitea/conf/app.ini"
    host_path      = abspath(local_file.forgejo_config.filename)
  }
}
