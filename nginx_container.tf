resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx_container" {
  name = "nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.web_network.name
  }

  ports {
    internal = 80
    external = 80
  }

#  ports {
#    internal = 443
#    external = 443
#  }

#  volumes {
#    host_path = "${path.cwd}/nginx/conf.d"
#    container_path = "/etc/nginx/conf.d"
#  }

#  volumes {
#    host_path = "${path.cwd}/nginx/html"
#    container_path = "/usr/share/nginx/html"
#  }

#  volumes {
#    host_path = "${path.cwd}/nginx.certs"
#    container_path = "/etc/nginx/certs"
#  }
}

