locals {
  webui_public_url    = "https://chat.${var.HOST_NAME}"
  openid_discovery    = "https://auth.${var.HOST_NAME}/application/o/${var.OPENWEBUI_AUTHENTIK_PROVIDER_SLUG}/.well-known/openid-configuration"
  openid_redirect     = "${local.webui_public_url}/oauth/oidc/callback"
  ollama_base_trimmed = trim(var.OPENWEBUI_OLLAMA_BASE_URL, "/")
  oauth_env = [
    "WEBUI_URL=${local.webui_public_url}",
    "OAUTH_CLIENT_ID=${var.OPENWEBUI_OAUTH_CLIENT_ID}",
    "OAUTH_CLIENT_SECRET=${var.OPENWEBUI_OAUTH_CLIENT_SECRET}",
    "OAUTH_PROVIDER_NAME=authentik",
    "OPENID_PROVIDER_URL=${local.openid_discovery}",
    "OPENID_REDIRECT_URI=${local.openid_redirect}",
    "ENABLE_OAUTH_SIGNUP=true",
    "ENABLE_LOGIN_FORM=true",
    "OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true",
    "HF_TOKEN=${var.OPENWEBUI_HF_TOKEN}",
  ]
  ollama_env    = local.ollama_base_trimmed != "" ? ["OLLAMA_BASE_URL=${local.ollama_base_trimmed}"] : []
  container_env = concat(local.oauth_env, local.ollama_env)
}

resource "docker_container" "openwebui_container" {
  image = docker_image.openwebui_image.image_id
  name  = "openwebui_container"

  env = local.container_env

  # MagicDNS (*.ts.net) for OPENWEBUI_OLLAMA_BASE_URL does not resolve through Docker’s
  # default resolver on many hosts; Tailscale’s DNS at 100.100.100.100 handles tailnet names.
  # Fallback keeps public lookups working if MagicDNS is unavailable.
  dns = ["100.100.100.100", "1.1.1.1"]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 8080
  }

  volumes {
    host_path      = "${var.STATE_PATH}/data"
    container_path = "/app/backend/data"
  }

  labels {
    label = "traefik.http.routers.chat.rule"
    value = "Host(`chat.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.chat.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.chat.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.chat.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.chat.middlewares"
    value = "public"
  }

  labels {
    label = "traefik.http.routers.chat.service"
    value = "chat"
  }

  labels {
    label = "traefik.http.services.chat.loadbalancer.server.port"
    value = "8080"
  }
}
