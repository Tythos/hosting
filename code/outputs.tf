output "FORGEJO_REDIRECT_URI" {
  value       = "https://code.${var.HOST_NAME}/user/oauth2/Authentik/callback"
  description = "OAuth2 Redirect URI for Forgejo application"
}
