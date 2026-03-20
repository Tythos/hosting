output "OPENWEBUI_WEBUI_URL" {
  value       = "https://chat.${var.HOST_NAME}"
  description = "Public base URL for Open WebUI (must match Authentik redirect host and WEBUI_URL)"
}

output "OPENWEBUI_OPENID_REDIRECT_URI" {
  value       = "https://chat.${var.HOST_NAME}/oauth/oidc/callback"
  description = "OAuth OIDC redirect URI registered in Authentik for Open WebUI"
}
