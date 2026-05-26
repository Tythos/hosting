resource "local_file" "acquis_config" {
  filename        = abspath("${path.module}/acquis.yaml")
  file_permission = "0644"
  content         = <<-EOT
filenames:
  - /var/log/traefik/access.log
labels:
  type: traefik
EOT
}

resource "null_resource" "deploy_acquis" {
  triggers = {
    config_digest = local_file.acquis_config.content_md5
  }

  provisioner "local-exec" {
    command = "mkdir -p '${var.STATE_PATH}/config' && cp '${local_file.acquis_config.filename}' '${var.STATE_PATH}/config/acquis.yaml'"
  }

  depends_on = [local_file.acquis_config]
}

resource "null_resource" "install_crowdsec_scenarios" {
  triggers = {
    acquis_digest = local_file.acquis_config.content_md5
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker exec crowdsec_container cscli scenarios install \
        crowdsecurity/http-crawl-non_statics \
        crowdsecurity/http-probing \
        crowdsecurity/http-bad-user-agent \
        crowdsecurity/http-sensitive-files \
        crowdsecurity/http-generic-bf || true
      docker exec crowdsec_container cscli reload || true
    EOT
  }

  depends_on = [
    null_resource.deploy_acquis,
    docker_container.crowdsec_container
  ]
}
