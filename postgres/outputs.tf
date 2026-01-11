output "POSTGRES_PASSWORD" {
  value     = random_password.postgres_password.result
  sensitive = true
}

output "POSTGRES_HOST" {
  value = docker_container.postgres_container.name
}

output "CONSUMER_CREDENTIALS" {
  description = "Credentials for each consumer module"
  value = {
    for name, config in var.CONSUMERS : name => {
      host     = docker_container.postgres_container.name
      username = config.username
      password = random_password.consumer_passwords[name].result
      database = coalesce(config.database, config.username)
    }
  }
  sensitive = true
}
