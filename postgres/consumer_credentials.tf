# Generate a unique password for each consumer
resource "random_password" "consumer_passwords" {
  for_each = var.CONSUMERS

  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}

# Generate init script that creates users and databases (runs on first initialization)
resource "local_file" "init_consumers" {
  count    = length(var.CONSUMERS) > 0 ? 1 : 0
  filename = "${path.module}/init-consumers.sql"
  content = join("\n", concat(
    [
      for name, config in var.CONSUMERS : <<-EOT
        -- Create user and database for ${name}
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${config.username}') THEN
            CREATE USER ${config.username} WITH PASSWORD '${random_password.consumer_passwords[name].result}';
          END IF;
        END
        $$;
        SELECT 'CREATE DATABASE ${coalesce(config.database, config.username)} OWNER ${config.username}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${coalesce(config.database, config.username)}')\gexec
        GRANT ALL PRIVILEGES ON DATABASE ${coalesce(config.database, config.username)} TO ${config.username};
      EOT
    ],
    [
      for name, config in var.CONSUMERS : <<-EOT
        \c ${coalesce(config.database, config.username)}
        GRANT ALL ON SCHEMA public TO ${config.username};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${config.username};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${config.username};
      EOT
    ]
  ))
}

# Execute SQL to sync consumers (runs whenever passwords or consumers change)
resource "null_resource" "sync_consumers" {
  for_each = var.CONSUMERS
  depends_on = [
    docker_container.postgres_container
  ]

  triggers = {
    password       = random_password.consumer_passwords[each.key].result
    username       = each.value.username
    database       = coalesce(each.value.database, each.value.username)
    container_id   = docker_container.postgres_container.id
    schema_version = "1" # Increment to force re-run of provisioner
  }

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${each.value.username}') THEN CREATE USER ${each.value.username} WITH PASSWORD '${replace(random_password.consumer_passwords[each.key].result, "'", "''")}'; ELSE ALTER USER ${each.value.username} WITH PASSWORD '${replace(random_password.consumer_passwords[each.key].result, "'", "''")}'; END IF; END \$\$;"
      DB_EXISTS=$(PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${coalesce(each.value.database, each.value.username)}'")
      if [ -z "$DB_EXISTS" ]; then
        PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "CREATE DATABASE ${coalesce(each.value.database, each.value.username)} OWNER ${each.value.username};"
      fi
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${coalesce(each.value.database, each.value.username)} TO ${each.value.username};"
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d ${coalesce(each.value.database, each.value.username)} -c "GRANT ALL ON SCHEMA public TO ${each.value.username}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${each.value.username}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${each.value.username};"
    EOT
  }
}
