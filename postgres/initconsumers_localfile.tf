resource "local_file" "init_consumers" {
  count    = length(var.CONSUMERS) > 0 ? 1 : 0
  filename = "${path.module}/init-consumers.sql"
  content = join("\n", concat(
    [
      for identifier, password in var.CONSUMERS : <<-EOT
        -- Create user and database for ${identifier}
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${identifier}') THEN
            CREATE USER ${identifier} WITH PASSWORD '${replace(password, "'", "''")}';
          END IF;
        END
        $$;
        SELECT 'CREATE DATABASE ${identifier} OWNER ${identifier}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${identifier}')\gexec
        GRANT ALL PRIVILEGES ON DATABASE ${identifier} TO ${identifier};
      EOT
    ],
    [
      for identifier, password in var.CONSUMERS : <<-EOT
        \c ${identifier}
        GRANT ALL ON SCHEMA public TO ${identifier};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${identifier};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${identifier};
      EOT
    ]
  ))
}
