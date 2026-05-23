# hosting

## Background

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

1. **Add the `authentik-auth` middleware** to the service router by including `traefik.http.routers.<name>.middlewares = "authentik-auth"` among the labels. This gates the service behind Authentik single sign-on. If the service is intentionally public (e.g. a landing page), reference the `public` bypass middleware instead: `traefik.http.routers.<name>.middlewares = "public"`. Services with their own Authentik OIDC integration (like Forgejo or Open WebUI) should also use `public` to avoid a double-auth loop.

**Setup Instructions**: See [AUTHENTIK_FORGEJO_SETUP.md](./AUTHENTIK_FORGEJO_SETUP.md) for detailed manual configuration steps for both Authentik (provider) and Forgejo (client).

**Retrieve OAuth2 Credentials**:
```bash
terraform output -raw module.code.FORGEJO_OAUTH_CLIENT_SECRET
terraform output module.code.FORGEJO_REDIRECT_URI
```

**Key Features**:
- Single Sign-On (SSO) for Forgejo via Authentik
- Auto-registration of users on first login
- Support for both local and OAuth2 authentication methods
- Secure client secret generation via Terraform

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

- Next step, then, is to back out (or at least document) 0references to the resources set up by the manual process to inspect/replicate a test rule for verification:

  - Address registration (`cloudflare_email_routing_address`, but may require manual entry for verification)

  - Routing rule (`cloudflare_email_routing_rule`)

  - 3x `MX` records (`cloudflare_dns_record`) mapping hostname to `route(1|2|3).mx.cloudflare.net`

  - 1x `TXT` records (`cloudflare_dns_record`) mapping the CF `domainkey` record for the hostname to a `v=DKIM1;...` value

  - 1x `TXT` record (`cloudflare_dns_record`) mapping hostname to a `v=spf1...` value; *THIS ONE INCLUDES A CRYPTOGRAPHIC KEY THAT WILL LIKELY BE DIFFICULT, IF NOT IMPOSSIBLE, TO GENERATE/POPULATE PROCEDURALLY FROM TERRAFORM*

  - One wonders if some combination of the above is automatically populated/generated by a `cloudflare_email_routing_dns ` resource
