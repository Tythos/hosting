resource "local_file" "logrotate_config" {
  filename        = abspath("${path.module}/logrotate-traefik")
  file_permission = "0644"
  content         = <<-EOT
    ${var.TRAEFIK_LOG_PATH}/access.log {
      size 100M
      rotate 7
      compress
      delaycompress
      missingok
      notifempty
      postrotate
        docker kill -s HUP traefik_container > /dev/null 2>&1 || true
      endscript
    }
  EOT
}

resource "null_resource" "deploy_logrotate" {
  triggers = {
    config_digest = local_file.logrotate_config.content_md5
  }

  provisioner "local-exec" {
    command = "cp '${local_file.logrotate_config.filename}' /etc/logrotate.d/traefik && chmod 644 /etc/logrotate.d/traefik"
  }

  depends_on = [local_file.logrotate_config]
}
