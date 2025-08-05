resource "cloudflare_email_routing_address" "mailmanaddress" {
  account_id = var.CF_ACCOUNT_ID
  email      = "${var.AUTOMATION_EMAIL_USER}@${var.HOST_NAME}"
}
