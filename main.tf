terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "proxy_network" {
  name = "proxy"
}

resource "docker_image" "traefik" {
  name = "traefik:v2.10"
}

resource "docker_container" "traefik" {
  name  = "traefik"
  image = docker_image.traefik.image_id
  
  restart = "unless-stopped"
  
  ports {
    internal = 80
    external = 80
  }
  
  ports {
    internal = 443
    external = 443
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  
  volumes {
    host_path      = "${path.cwd}/data/traefik.yml"
    container_path = "/traefik.yml"
    read_only      = true
  }
  
  volumes {
    host_path      = "${path.cwd}/data/acme.json"
    container_path = "/acme.json"
  }

  networks_advanced {
    name = docker_network.proxy_network.name
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.traefik.entrypoints"
    value = "http"
  }

  labels {
    label = "traefik.http.routers.traefik.rule"
    value = "Host(`traefik.tythos.io`)"
  }

  labels {
    label = "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme"
    value = "https"
  }

  labels {
    label = "traefik.http.routers.traefik.middlewares"
    value = "traefik-https-redirect"
  }

  labels {
    label = "traefik.http.routers.traefik-secure.entrypoints"
    value = "https"
  }

  labels {
    label = "traefik.http.routers.traefik-secure.rule"
    value = "Host(`traefik.tythos.io`)"
  }

  labels {
    label = "traefik.http.routers.traefik-secure.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.traefik-secure.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.traefik-secure.service"
    value = "api@internal"
  }
}