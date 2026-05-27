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

- [x] **8.2** - *Traefik Middleware: Global Bad-Path Blocking*: This is the highest-leverage, lowest-effort win. Traefik supports Plugin and native IPAllowList/Headers middleware, but we can also use a redirectRegex or — better — a custom blockList via a plugin middleware or a chain with stripPrefix + a catch-all 403.

  - [x] **8.2.1** - Deploy a "blackhole" container (nginx:alpine returning 403) registered as a Traefik service
  - [x] **8.2.2** - Define HostRegexp + PathPrefix blocking routers on Traefik for common scanner probe paths
  - [x] **8.2.3** - Add Loki logging to the blackhole container for blocked-request auditing
  - [x] **8.2.4** - Verify blocking works and normal traffic is unaffected

- [x] **8.3** - *Authentik Forward Auth as Default Middleware*: We already have Authentik running. The missing piece is making it the default for anything that isn't explicitly public, rather than opt-in per service. Traefik's forwardAuth middleware can be defined once and applied via an entryPoints-level middleware chain (note: entrypoint-level middleware cannot be bypassed at the router level, so we use a router-level convention — every service gets the auth middleware unless explicitly listed as public):

  - [x] **8.3.1** - Define `authentik-auth` forwardAuth middleware on the Traefik container pointing at `http://authentik_server_container:9000/outpost.goauthentik.io/auth/traefik`, with auth response headers forwarded
  - [x] **8.3.2** - Define `public` bypass middleware (empty chain) on the Traefik container for services that should remain accessible without auth
  - [x] **8.3.3** - Add `authentik-auth` middleware label to every non-public service module (adminer, aero, cc, easton, flask, grafana, kifiew, macercy, scotland, seafile, smogwarts, spain)
  - [x] **8.3.4** - Migrate Traefik dashboard from `basic-auth` to `authentik-auth` (chained for defense-in-depth)
  - [x] **8.3.5** - Verify auth gate works on protected services and public services (resume, whoami) are unaffected; confirm code/Forgejo and openwebui (which have their own OIDC flows) are not double-authed
  - [x] **8.3.6** - Update README.md "Extension" section to document that new services should include the `authentik-auth` middleware label unless they are intentionally public

- [ ] **8.4** - *CrowdSec Sidecar for Repeat Offenders*: The above approaches block known-bad patterns, but they don't dynamically ban IPs that are repeatedly probing. CrowdSec reads log streams (here: Traefik HTTP access logs via a shared volume), detects attack patterns with community scenarios, and feeds IP bans back into Traefik via a forward-auth bouncer container — consistent with our Authentik auth pattern.

  - [x] **8.4.1** - Deploy CrowdSec LAPI+agent container (`crowdsecurity/crowdsec`), connected to `hosting_network`, with persistent state under `MOUNTED_VOLUME/crowdsec/` and a volume mount for Traefik access log acquisition
  - [x] **8.4.2** - Configure Traefik to write structured HTTP access logs to a shared host volume (`MOUNTED_VOLUME/traefik/access.log`) in a CrowdSec-compatible format, and mount it into the CrowdSec container for consumption
  - [x] **8.4.3** - Configure CrowdSec agent acquisition to tail the Traefik access log file, and enable the official Traefik parser and HTTP attack scenarios (`crowdsecurity/http-crawl-non_statics`, `crowdsecurity/http-probing`, `crowdsecurity/http-bad-user-agent`, etc.)
  - [x] **8.4.4** - Deploy CrowdSec Traefik Bouncer container (`crowdsecurity/traefik-bouncer`) connected to `hosting_network`, configured to query the local LAPI for ban decisions and expose an HTTP endpoint suitable for forwardAuth
  - [x] **8.4.5** - Define `crowdsec-bouncer` forwardAuth middleware on the Traefik container (pointing at the bouncer container), and add it before the existing `authentik-auth` middleware in a new `secured` chain; create a `public` chain with only the bouncer for public-facing services
  - [x] **8.4.6** - Update all service module middleware labels to reference the appropriate chain (`secured` for non-public, `public` for public/OIDC services) and uncomment currently-disabled ones
  - [x] **8.4.7** - Verify that simulated scanning probes trigger a CrowdSec ban decision and that the banned source IP receives a 403 from Traefik, while legitimate traffic passes through to Authentik or the target service unaffected
  - [x] **8.4.8** - Optionally enable CrowdSec's Prometheus metrics endpoint and add a Grafana dashboard panel for ban activity / alerting
