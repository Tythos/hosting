output "TRAEFIK_PASSWORD" {
  value     = random_password.traefik_password.result
  sensitive = true
}

output "SERVICE_URLS" {
  description = "URLs for all deployed services"
  value = {
    for k, v in var.services : k => "https://${lookup(v, "subdomain", k)}.${var.HOST_DOMAIN}"
  }
}

output "DASHBOARD_URL" {
  value = "https://traefik.${var.HOST_DOMAIN}"
}

output "TEST_URL" {
  value = "https://test.${var.HOST_DOMAIN}"
}
