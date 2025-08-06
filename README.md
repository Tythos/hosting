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

1. Add labels to the `docker_container` indicating how it should be identified/routed; for secured endpoints, the router labels should define relevant TLS options, and logging options should be included if service reports will be aggregated

## Observability

- [x] *Metrics*: Prometheus for metrics collection from metaservices, host node, and containerized services/applications; node-exporter for host resource metrics (through Prometheus)

- [x] *Logs*: Loki for aggregation/storage/exposure (via Loki Docker plugin driver)

- [x] *Tracing*: Tempo with OTEL instrumentation (particularly useful with the `opentelemetry-instrument` middleware/launcher/wrapper for Flask)

Grafana is the primary presentation target for dashboarding each observability signal.

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

  - Non-hosted

    - [x] Kifiew

    - [ ] Jabber

    - [ ] Barebones

    - [ ] Cuben

    - [ ] Engine

    - [ ] (miscellaneous)

  - [x] Macercy

  - [x] Aero

  - [ ] Culinary Colqhoun

  - [ ] Conferences?

  - [ ] Controls?

  - [ ] Creatives

  - [ ] KMZ/Geoint

  - [ ] Leroy

  - [ ] No Debt Unpaid

  - [ ] The Writing Horse

  - [ ] Wallpapers

- [x] Honestly it wouldn't be a bad idea to demo and/or port a PHP app from the above list  

- [x] Once TLS is implemented we need to "lock down" all other endpoints and put the dashboard behind a login

- [ ] Migrate to OpenTofu?

- [ ] Demonstrate/pathfind a database integration of some kind?

- Replace tythos.net

  - [ ] Migrate domain registration to Cloudflare

  - [ ] Change TLD in HOST_NAME value

  - [ ] Update Cloudflare parameters (zone, etc.)

  - [ ] Force renewal of all certificates

  - [ ] Remove/shutdown all old resources/subscriptsion

  - [ ] Optionally look at migrating/merging Minecraft server as well?

## Status/Health cURL Queries

To verify node-exporter is exposing metrics:

```sh
docker exec traefik_container curl http://node_exporter_container:9100/metrics
```

To verify Prometheus is exposing reports:

```sh
docker exec traefik_container curl http://prometheus_container:9090/api/v1/query --data-urlencode 'query=up{job="prometheus"}'
```

To inject a log message into Loki manually:

```sh
docker exec traefik_container curl -X POST -d '{"streams":[{"stream":{"container":"test"},"values":[["'$(date +%s%N)'","test log message"]]}]}' -H "Content-Type: application/json" http://loki_container:3100/loki/api/v1/push
```

Assuming Tempo is up and an appropriate app is running (we use "flask-app" here), tracing can be verified via:

```sh
docker exec traefik_container curl http://tempo_container:3200/ready
docker exec traefik_container curl "http://tempo_container:3200/api/search?tags=service.name%3Dflask-app&limit=10"
```

## Email Traffic

We have set up a Resend account for integration with client services within this orchestration (see `flask` application).

This is configured to support *outgoing* traffic via addresses specific to this subdomain, but by default we construct one (`notifications@`) at the top level to share.

We would also like to support forwarding for *incoming* traffic, likely to the same address used in ACME registration (for simplicity's sake), but:

- This did not work via expected Terraform providers

- It did finally work when we set it up manually in the CF dashboard

- Hopefully this wasn't because of the email verification requirement/step (which obviously couldn't be automated)

- Hopefully this *was* because we need to get the right combination of resources defined (addresses, rules, etc.)

- Next step, then, is to back out (or at least document) 0references to the resources set up by the manual process to inspect/replicate a test rule for verification

## Sliplane Services

From the following great article:

https://dev.to/code42cate/how-i-save-by-self-hosting-these-5-open-source-tools-17mb

- [x] Plunk (used Resend instead)

- [x] n8n (neat but might not keep? could use as an ai-enabled argo/flux replacement, i suppose)

- [ ] Postgres

- [ ] Nextcloud (minio instead?)

- [ ] Redis
