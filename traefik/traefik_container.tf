resource "docker_container" "traefik_container" {
  name  = "traefik_container"
  image = docker_image.traefik_image.image_id

  command = [
    "--api.dashboard=true",
    "--providers.docker",
    "--entrypoints.web.address=:80",
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--entrypoints.web.http.redirections.entrypoint.permanent=true",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.ssh.address=:2222",
    "--entrypoints.minecraft.address=:25565",
    "--log.level=INFO",
    "--certificatesresolvers.letsencrypt.acme.email=${var.ACME_EMAIL}",
    "--certificatesresolvers.letsencrypt.acme.storage=/etc/letsencrypt/acme.json",
    "--certificatesresolvers.letsencrypt.acme.caserver=${var.LETSENCRYPT_ORIGIN}",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
    "--metrics.prometheus=true",
    "--metrics.prometheus.addEntryPointsLabels=true",
    "--metrics.prometheus.addRoutersLabels=true",
    "--metrics.prometheus.addServicesLabels=true",
    # "--metrics.prometheus.scrape=true",
    # "--metrics.prometheus.port=8080",
    # "--metrics.prometheus.job=traefik",
    "--metrics.addinternals"
  ]

  env = [
    "CF_API_EMAIL=${var.ACME_EMAIL}",
    "CF_API_KEY=${var.CF_API_KEY}",
    "CF_DNS_API_TOKEN=${var.CF_DNS_API_TOKEN}"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 25565
    external = 25565
  }

  ports {
    internal = 2222
    external = 2222
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/etc/letsencrypt"
    container_path = "/etc/letsencrypt"
  }

  # labels for the dashboard itself are assigned via router w/ middleware

  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = "Host(`dashboard.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "basic-auth"
  }

  labels {
    label = "traefik.http.middlewares.basic-auth.basicAuth.users"
    value = "admin:${var.ADMIN_PASSWORD}"
  }

  labels {
    label = "traefik.http.middlewares.redirect-main.redirectregex.regex"
    value = "^https?://(www\\.)?${var.HOST_NAME}(/.*)?$$"
  }

  labels {
    label = "traefik.http.middlewares.redirect-main.redirectregex.replacement"
    value = "https://resume.${var.HOST_NAME}/"
  }

  labels {
    label = "traefik.http.middlewares.redirect-main.redirectregex.permanent"
    value = "true"
  }

  # Dummy service for redirect-only routers
  labels {
    label = "traefik.http.services.noop.loadbalancer.server.port"
    value = "80"
  }

  # Router for HTTPS root domain redirect
  labels {
    label = "traefik.http.routers.root.rule"
    value = "Host(`${var.HOST_NAME}`) || Host(`www.${var.HOST_NAME}`)"
  }

  labels {
    label = "traefik.http.routers.root.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.root.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.root.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.root.middlewares"
    value = "redirect-main"
  }

  labels {
    label = "traefik.http.routers.root.service"
    value = "noop"
  }

  # ── Bad-path blocking routers ──────────────────────────────────────────
  # Each router matches HostRegexp (any subdomain) + PathPrefix (scanner path)
  # and routes to the blackhole container (403).  High priority ensures the
  # block is evaluated before the target service router.

  dynamic "labels" {
    for_each = local.blocked_paths
    content {
      label = "traefik.http.routers.block-${labels.key}.rule"
      value = "HostRegexp(`^[a-zA-Z0-9-]+\\.${replace(var.HOST_NAME, ".", "\\.")}$`) && PathPrefix(`${labels.value}`)"
    }
  }

  dynamic "labels" {
    for_each = local.blocked_paths
    content {
      label = "traefik.http.routers.block-${labels.key}.priority"
      value = "100"
    }
  }

  dynamic "labels" {
    for_each = local.blocked_paths
    content {
      label = "traefik.http.routers.block-${labels.key}.entrypoints"
      value = "websecure"
    }
  }

  dynamic "labels" {
    for_each = local.blocked_paths
    content {
      label = "traefik.http.routers.block-${labels.key}.tls"
      value = "true"
    }
  }

  dynamic "labels" {
    for_each = local.blocked_paths
    content {
      label = "traefik.http.routers.block-${labels.key}.service"
      value = "blackhole@docker"
    }
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "8080"
  }

  labels {
    label = "prometheus.job"
    value = "traefik"
  }
}

locals {
  blocked_paths = {
    env            = "/.env"
    git            = "/.git"
    aws            = "/.aws"
    ssh            = "/.ssh"
    wp_admin       = "/wp-admin"
    wp_login       = "/wp-login"
    xmlrpc         = "/xmlrpc.php"
    admin          = "/admin"
    administrator  = "/administrator"
    backup         = "/backup"
    bitrix         = "/bitrix"
    config         = "/config"
    debug          = "/debug"
    test           = "/test"
    console        = "/console"
    actuator       = "/actuator"
    vendor         = "/vendor"
    cgi_bin        = "/cgi-bin"
    server_status  = "/server-status"
    server_info    = "/server-info"
    composer       = "/composer.json"
    package        = "/package.json"
    docker_compose = "/docker-compose"
    phpinfo        = "/phpinfo.php"
    info           = "/info.php"
    shell          = "/shell.php"
    procfile       = "/Procfile"
    dockerfile     = "/Dockerfile"
  }
}
