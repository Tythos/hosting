output "FORGEJO_OAUTH_CLIENT_ID" {
  value       = "forgejo"
  description = "OAuth2 Client ID for Forgejo application in Authentik"
}

output "FORGEJO_OAUTH_CLIENT_SECRET" {
  value       = random_password.forgejo_oauth_client_secret.result
  description = "OAuth2 Client Secret for Forgejo application in Authentik"
  sensitive   = true
}

output "FORGEJO_REDIRECT_URI" {
  value       = "https://code.${var.HOST_NAME}/user/oauth2/Authentik/callback"
  description = "OAuth2 Redirect URI for Forgejo application"
}
