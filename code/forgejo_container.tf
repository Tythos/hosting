resource "local_file" "forgejo_config" {
  filename        = "${path.module}/app.ini"
  file_permission = "0666"
  content = templatefile("${path.module}/app.ini.tftpl", {
    domain                  = "code.${var.HOST_NAME}"
    secret_key              = random_password.forgejosecretkey_randompassword.result
    internal_token          = random_password.forgejointernaltoken_randompassword.result
    authentik_client_id     = var.FORGEJO_OAUTH_CLIENT_ID
    authentik_client_secret = var.FORGEJO_OAUTH_CLIENT_SECRET
    authentik_domain        = "auth.${var.HOST_NAME}"
  })
}

resource "null_resource" "forgejo_auth_source" {
  provisioner "local-exec" {
    command = <<-EOT
      # Wait for Forgejo
      until docker exec forgejo_container forgejo --version 2>/dev/null; do
        sleep 2
      done
      sleep 5
      
      # Check if already exists
      if ! docker exec -u git forgejo_container forgejo admin auth list 2>/dev/null | grep -q authentik; then
        docker exec -u git forgejo_container forgejo admin auth add-oauth \
          --name authentik \
          --provider openidConnect \
          --key "${var.FORGEJO_OAUTH_CLIENT_ID}" \
          --secret "${var.FORGEJO_OAUTH_CLIENT_SECRET}" \
          --auto-discover-url "https://auth.${var.HOST_NAME}/application/o/forgejo/.well-known/openid-configuration" \
          --scopes "openid email profile" \
          --skip-local-2fa
      else
        echo "Auth source already exists, skipping"
      fi
    EOT
  }

  depends_on = [
    docker_container.forgejo_container
  ]
  
  triggers = {
    # Re-run if credentials change
    client_id = var.FORGEJO_OAUTH_CLIENT_ID
    client_secret = var.FORGEJO_OAUTH_CLIENT_SECRET
    # But don't re-run every time
    config_version = "v1"
  }
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
