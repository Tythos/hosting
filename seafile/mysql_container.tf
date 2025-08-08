resource "docker_container" "mysql_container" {
  image = docker_image.mysql_image.image_id
  name  = "mysql_container"

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.db_password.result}",
    "MYSQL_LOG_CONSOLE=true",
    "MARIADB_AUTO_UPGRADE=1"
  ]

  networks_advanced {
    name = var.HOSTING_NETWORK_NAME
  }

  volumes {
    host_path      = "${var.STATE_PATH}/mysql"
    container_path = "/var/lib/mysql"
  }
}
