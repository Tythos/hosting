# hosting

## background

This project defines a Terraform-based deployment of multi-service hosting configuration.

Individual services are assumed to be defined as Docker containers (e.g. via the `docker_container` resource).

Service discovery and mesh configuration (including middleware and routing) is handled by a Traefik instance, which is also defined in Terraform as a Docker container.

The immediate goal is to migrate older VPS resources from my old server to a Droplet on DigitalOcean, but using more modern (automated and minimal) infrastructure.

## TODO

- [x] Routing (and load balancing)

- [ ] HTTPS / TLS

- [ ] Other middleware (redirect?)

- [ ] Templated traefik configuration (static yaml?)

- [x] Initial nginx-based service

- [ ] Initial static content host via above from specific volume

- [ ] Migrate volume contents

- [ ] We've exposed basic logging metrics in a prometheus format, but these should be aggregated and exposed for management/monitoring

- [ ] Once TLS is implemented we need to "lock down" all other endpoints and put the dashboard behind a login
