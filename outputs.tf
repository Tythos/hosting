output "ADMIN_PASSWORD" {
  value     = module._credentials.ADMIN_PASSWORD
  sensitive = true
}

output "TEMPO_ENDPOINT" {
  value = module.tempo.TEMPO_ENDPOINT
}

output "POSTGRES_PASSWORD" {
  value     = module.postgres.POSTGRES_PASSWORD
  sensitive = true
}

output "FORGEJO_REDIRECT_URI" {
  value       = module.code.FORGEJO_REDIRECT_URI
  description = "OAuth2 Redirect URI for Forgejo"
}

output "OPENWEBUI_OPENID_REDIRECT_URI" {
  value       = module.openwebui.OPENWEBUI_OPENID_REDIRECT_URI
  description = "OAuth OIDC redirect URI for Open WebUI (Authentik)"
}

output "OPENWEBUI_WEBUI_URL" {
  value       = module.openwebui.OPENWEBUI_WEBUI_URL
  description = "Public WEBUI_URL for Open WebUI"
}
