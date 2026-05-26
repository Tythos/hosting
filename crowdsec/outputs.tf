output "CROWDSEC_BOUNCER_API_KEY" {
  value     = random_password.bouncer_api_key.result
  sensitive = true
}
