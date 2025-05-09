# hosting

## background

This project defines a Terraform-based deployment of multi-service hosting configuration.

Individual services are assumed to be defined as Docker containers (e.g. via the `docker_container` resource).

Service discovery and mesh configuration (including middleware and routing) is handled by a Traefik instance, which is also defined in Terraform as a Docker container.

The immediate goal is to migrate older VPS resources from my old server to a Droplet on DigitalOcean, but using more modern (automated and minimal) infrastructure.

The VM itself is expected to be running a recent version of Docker, and Terraform will be used to define and manage the Docker containers--so an active Docker service should be running and accessible with the appropriate privileges.

## Variables

See `variables.tf` for more details; variable values can be passed in by environmental variables (utilizing the `TF_VAR_` prefix) or in the contents of a `terraform.tfvars` file (which is ignored by version control). There are some related assumptions, however.

Specifically, this project does assume the target VM already has A records for the `HOST_NAME` defined in the corresponding Terraform variable; this should include both top-level ("`@`") and subdomain wildcard ("`*`") records, and should point at the VM address.

## TLS Certificates

We assume Cloudflare is being used as the DNS provider for Let's Encrypt certificate requests.

Other providers can be used but will require modification to the Traefik configuration options.

You may also need to pass through different sets of variables to support different challenge exchanges.

More details can be found in the Traefik documentation:

https://doc.traefik.io/traefik/https/acme/#dnschallenge

## Extension

To define a new service:

1. Add a new `docker_image` resource (assuming it is not already being referenced/used)

1. Add a new `docker_container` resource, mounting against any particular persistent storage requirements

1. Add labels to the `docker_container` indicating how it should be identified/routed; for secured endpoints, the router labels should define relevant TLS options

## TODO

- [x] Routing (and load balancing)

- [x] HTTPS / TLS

- [ ] Other middleware (redirect?)

- [ ] Templated traefik configuration (static yaml?)

- [x] Initial nginx-based service

- [ ] Initial static content host via above from specific volume

- [ ] Migrate volume contents

- [ ] We've exposed basic logging metrics in a prometheus format, but these should be aggregated and exposed for management/monitoring

- [ ] Once TLS is implemented we need to "lock down" all other endpoints and put the dashboard behind a login
