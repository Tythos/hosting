# TODO

## Phase 1 - Fundamentals

- [x] **1.1** - Routing (and load balancing)

- [x] **1.2** - HTTPS / TLS

- [x] **1.3** - Other middleware (redirect? basicauth, actually)

- [x] **1.4** - Initial nginx-based service

- [x] **1.5** - Initial static content host via above from specific volume

## Phase 2 - Migrate Hosted Volume Contents

- [x] **2.1** - Smogwarts

- [x] **2.2** - Resume

- [x] **2.3** - Macercy

- [x] **2.4** - Aero

- [ ] **2.5** - Culinary Colqhoun

- [ ] **2.6** - Conferences?

- [ ] **2.7** - Controls?

- [ ] **2.8** - Creatives

- [ ] **2.9** - KMZ/Geoint

- [ ] **2.10** - Leroy

- [ ] **2.11** - No Debt Unpaid

- [ ] **2.12** - The Writing Horse

- [ ] **2.13** - Wallpapers

## Phase 3 - Migrate Non-Hosted Contents

- [x] **3.1** - Kifiew

- [ ] **3.2** - Jabber

- [ ] **3.3** - Barebones

- [ ] **3.4** - Cuben

- [ ] **3.5** - Engine

- [ ] **3.6** - (miscellaneous static content)

## Phase 4 - Infrastructure Follow-On

- [x] **4.1** - Demo and/or port a PHP app from the above list  

- [x] **4.2** - Once TLS is implemented we need to "lock down" all other endpoints and put the dashboard behind a login

- [ ] **4.3** - Migrate to OpenTofu?

- [ ] **4.4** - Demonstrate/pathfind a database integration of some kind?

- [x] **4.5** - *Metrics*: Prometheus for metrics collection from metaservices, host node, and containerized services/applications; node-exporter for host resource metrics (through Prometheus)

- [x] **4.6** - *Logs*: Loki for aggregation/storage/exposure (via Loki Docker plugin driver)

- [x] **4.7** - *Tracing*: Tempo with OTEL instrumentation (particularly useful with the `opentelemetry-instrument` middleware/launcher/wrapper for Flask)

- [x] **4.8** - Authentik instance configured as identity provider (`auth.${HOST_NAME}`)

- [x] **4.9** - Forgejo configured to support OAuth2/OIDC authentication

- [x] **4.10** - OAuth2 client credentials managed via Terraform (client secret auto-generated)

- [x] **4.11** - Environment variables configured for OpenID Connect auto-registration

## Phase 5 - Complete tythos.net Replacement

- [x] **5.1** - Migrate domain registration to Cloudflare

- [ ] **5.2** - Change TLD in HOST_NAME value

- [x] **5.3** -Update Cloudflare parameters (zone, etc.)

- [ ] **5.4** - Force renewal of all certificates

- [ ] **5.5** - Remove/shutdown all old resources/subscriptsion

- [ ] **5.6** - Optionally look at migrating/merging Minecraft server as well?

## Phase 6 - Sliplane Services

From the following great article:

https://dev.to/code42cate/how-i-save-by-self-hosting-these-5-open-source-tools-17mb

- [x] **6.1** - Plunk (used Resend instead)

- [ ] **6.2** - Configure and verify Grafana alerts integration with Resend

- [x] **6.3** - n8n (neat but might not keep? could use as an ai-enabled argo/flux replacement, i suppose)

- [x] **6.4** - Postgres (we also included Adminer as a management and verification app)

- [x] **6.5** - Seafile (alternative to Nextcloud, minio)

- [x] **6.6** - Redis

## Phase 7 - Household Utilities

- [ ] **7.1** - Media server of some kind? (bonus points for Roku channel support)

- [x] **7.2** - Actual for budgeting purposes

- [ ] **7.4** - Coupler for provisioning a Grafana source from Actual database

- [ ] **7.5** - Stonks!

## Phase 8 - Hardening

We're seeing a lot of snooping every time a new service goes up. Which is strange because they're all on submodules so either someone's scraping the Github or they're divining service mappings from Traefik data. Some suggestions:

- [x] **8.1** - *Cloudflare WAF Rules (Free Tier Covers This)*: Since we're already using Cloudflare for DNS/TLS challenges, we're one toggle away from using it as an actual WAF. In our providers.tf / Cloudflare Terraform resources, add a ruleset to block scanners

- [ ] **8.2** - *Traefik Middleware: Global Bad-Path Blocking*: This is the highest-leverage, lowest-effort win. Traefik supports Plugin and native IPAllowList/Headers middleware, but we can also use a redirectRegex or — better — a custom blockList via a plugin middleware or a chain with stripPrefix + a catch-all 403.

  - [x] **8.2.1** - Deploy a "blackhole" container (nginx:alpine returning 403) registered as a Traefik service
  - [x] **8.2.2** - Define HostRegexp + PathPrefix blocking routers on Traefik for common scanner probe paths
  - [x] **8.2.3** - Add Loki logging to the blackhole container for blocked-request auditing
  - [x] **8.2.4** - Verify blocking works and normal traffic is unaffected

- [ ] **8.3** - *Authentik Forward Auth as Default Middleware*: We already have Authentik running. The missing piece is making it the default for anything that isn't explicitly public, rather than opt-in per service. Traefik's forwardAuth middleware can be defined once and applied via an entryPoints-level middleware chain:

- [ ] **8.4** - *Fail2Ban or CrowdSec Sidecar for Repeat Offenders*: The above approaches block known-bad patterns, but they don't actually ban IPs that are repeatedly probing. Since we have Loki already ingesting all our container logs, we can close the loop with CrowdSec — it reads logs, detects attack patterns, and feeds bans back into Traefik via a bouncer plugin. It's Docker-native and has a Traefik bouncer maintained by the CrowdSec team.

- [ ] **8.5** - *Reverse-Engineering the Discovery*: The wildcard cert vs. per-service cert question is worth checking in our Traefik config. If each docker_container label set is triggering individual ACME cert requests per subdomain, we're essentially announcing every new service to the internet the moment it starts. Switching to a single wildcard cert issued once (using the DNS challenge we already have Cloudflare wired for) would eliminate that signal entirely
