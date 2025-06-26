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

## Observability

- [x] *Metrics*: Prometheus for metrics collection from metaservices, host node, and containerized services/applications

- [ ] *Logs*: Promtail for log collection, Loki for aggregation and storage

- [ ] *Events*: ??

- [ ] *Tracing*: ??

- [ ] *Alerting*: ??

- [ ] *Processing/Caching*: Prometheus

- [ ] *Presentation*: Grafana for dashboarding

## TODO

- [x] Routing (and load balancing)

- [x] HTTPS / TLS

- [x] Other middleware (redirect? basicauth, actually)

- ~~[ ] Templated traefik configuration (static yaml? might not be a good idea)~~

- [x] Initial nginx-based service

- [x] Initial static content host via above from specific volume

- Migrate volume contents

  - [x] Smogwarts
   
  - [x] Resume

  - [ ] Non-hosted

  - [ ] Macercy

  - [ ] Aero?

  - [ ] Culinary Colqhoun?

  - [ ] Conferences

  - [ ] Controls

  - [ ] Creatives

  - [ ] KMZ/Geoint?

  - [ ] Leroy

  - [ ] No Debt Unpaid

  - [ ] Soduko/Kifiew

  - [ ] The Writing Horse

  - [ ] Wallpapers

  - [ ] Any other interesting top-level file contents

- [ ] Honestly it wouldn't be a bad idea to demo and/or port a PHP app from the above list  

- [ ] We've exposed basic logging metrics in a prometheus format, but these should be aggregated and exposed for management/monitoring

      - [x] METRICS: Prometheus for metrics collection

      - [x] LOGS: Promtail for log collection, Loki for aggregation and storage

      - [ ] EVENTS: ??

      - [x] PRESENTATION: Grafana for dashboarding

- [x] Once TLS is implemented we need to "lock down" all other endpoints and put the dashboard behind a login

- [ ] Migrate to OpenTofu?

- [ ] Demonstrate/pathfind a database integration of some kind?

- [ ] Redirect from tythos.net? (or replace TLD)

## Status/Health cURL Queries

```sh
curl http://prometheus_container:9090/api/v1/query --data-urlencode 'query=up{job="prometheus"}'
curl http://loki_container:3100/loki/api/v1/query_range --data-urlencode 'query={job="containers"}' --data-urlencode 'since=5m'
curl http://promtail_container:9080/ready
```
