resource "docker_container" "authentik_worker_container" {
  image = docker_image.authentik_image.image_id
  name  = "authentik_worker_container"

  env = [
    "AUTHENTIK_POSTGRESQL__HOST=${var.POSTGRES_HOSTNAME}",
    "AUTHENTIK_POSTGRESQL__NAME=auth",
    "AUTHENTIK_POSTGRESQL__USER=auth",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.POSTGRES_PASSWORD}",
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secretkey.result}",
  ]

  command = ["worker"]

  shm_size = 512

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    container_path = "/data"
    host_path      = "${var.STATE_PATH}/data"
  }

  volumes {
    container_path = "/templates"
    host_path      = "${var.STATE_PATH}/custom-templates"
  }

  volumes {
    container_path = "/certs"
    host_path      = "${var.STATE_PATH}/certs"
  }
}
