resource "random_password" "bouncer_api_key" {
  length  = 64
  special = false
}

resource "null_resource" "register_bouncer" {
  triggers = {
    key_hash = sha256(random_password.bouncer_api_key.result)
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker exec crowdsec_container cscli bouncers remove crowdsec-bouncer 2>/dev/null || true
      docker exec crowdsec_container cscli bouncers add crowdsec-bouncer \
        --key '${random_password.bouncer_api_key.result}'
    EOT
  }
}
