resource "null_resource" "sync_consumers" {
  for_each = var.CONSUMERS
  depends_on = [
    docker_container.postgres_container
  ]

  triggers = {
    password       = each.value
    username       = each.key
    database       = each.key
    container_id   = docker_container.postgres_container.id
    schema_version = "1" # Increment to force re-run of provisioner
  }

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${each.key}') THEN CREATE USER ${each.key} WITH PASSWORD '${replace(each.value, "'", "''")}'; ELSE ALTER USER ${each.key} WITH PASSWORD '${replace(each.value, "'", "''")}'; END IF; END \$\$;"
      DB_EXISTS=$(PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${each.key}'")
      if [ -z "$DB_EXISTS" ]; then
        PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "CREATE DATABASE ${each.key} OWNER ${each.key};"
      fi
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${each.key} TO ${each.key};"
      PGPASSWORD='${replace(random_password.postgres_password.result, "'", "'\"'\"'")}' docker exec postgres_container psql -U postgres -d ${each.key} -c "GRANT ALL ON SCHEMA public TO ${each.key}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${each.key}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${each.key};"
    EOT
  }
}
