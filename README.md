# hosting

Terraform-based VM hosting using Docker to orchestrate multiple services across secure subdomains.

- [ ] Add Traefik for TLS automation and subdomain routing / service monitoring

- [ ] Add NGINX static file hosting with volume mounting for default landing point

- [ ] Add Plunk as mail host

- [ ] Add n8n as automation engine

- [ ] Add postgress (volume-mounted) as state management database

- [ ] Add Nextcloud as file sharing / syncing

- [ ] Add Redis for caching layer

- [ ] Start porting other `.net` services

Note: for simplicity and security, all values defined in `variables.tf` must be implemented in a `terraform.tfvars`, which is ignored by version control. They can also be passed in from environmental variables by using the prefix `TF_VAR_`.
