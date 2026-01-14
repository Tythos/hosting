resource "local_file" "forgejo_config" {
  filename        = "${module.path}/app.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/forgejo-app.ini.tftpl", {
    db_type              = "postgres"
    db_host              = "forgejo-db:5432"
    disable_registration = "true"
    require_signin       = "false"
  })
}

resource "docker_container" "forgejo_container" {
  image = docker_image.forgejo_image.image_id
  name  = "forgejo_container"
  depends_on = [local_file.forgejo_config]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 22
    external = 2222
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
    host_path      = local_file.forgejo_config.filename
    container_path = "/data/gitea/conf/app.ini"
    read_only      = true
  }
}
