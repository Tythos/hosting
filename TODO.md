# Open WebUI + home GPU inference — implementation plan

This document outlines work to add **Open WebUI** to the existing Traefik + Docker + Authentik stack on DigitalOcean, and to **reach a local inference stack** (Ollama or compatible API on a home desktop with a 5060 Ti) over a **private VPN path**. Nothing here is implemented yet; review and approve before execution.

## Current baseline (repo context)

- **Edge**: Traefik (`traefik` module) terminates TLS and routes per-container Docker labels; pattern is `Host(\`subdomain.${var.HOST_NAME}\`)` + `websecure` + `letsencrypt`.
- **Identity**: Authentik (`auth` module) is exposed at `auth.${HOST_NAME}`.
- **Forgejo** uses **Authentik as an OIDC/OAuth provider inside the app** (client id/secret in `variables.tf` / `terraform.tfvars`), not Traefik `forwardAuth`. Open WebUI should follow a similar pattern unless you explicitly want a proxy provider in front of the whole site.

## Phase 1 — Open WebUI service (Terraform)

- [ ] 1.1 **Add a dedicated module** (e.g. `openwebui/`) consistent with `whoami`, `grafana`, `code`:
   - `docker_image` pinned to a specific `ghcr.io/open-webui/open-webui` tag (or your chosen image).
   - `docker_container` on `hosting_network`, named volume or bind under `${var.MOUNTED_VOLUME}/openwebui` for persistence.
   - **Traefik labels**: new hostname (decide subdomain: e.g. `chat`), TLS, `websecure`, service port (Open WebUI default is typically **8080** — confirm in image docs for the chosen tag).

- [ ] 1.2 **Wire the module in `main.tf`**: pass `HOST_NAME`, `HOSTING_NETWORK_NAME`, `STATE_PATH`, and any auth-related variables.

- [ ] 1.3 **Observability**: Basic RED/USE metrics presented within Grafana

## Phase 2 — Authentik “behind auth” (choose one integration style)

- [ ] 2.1 **Authentik admin**: create an **OAuth2/OpenID provider** + **application** for Open WebUI (or reuse patterns from the Forgejo app).

- [ ] 2.2 **Redirect / callback URL** Open WebUI expects (depends on `WEBUI_URL` / public URL — typically `https://<subdomain>.<HOST_NAME>/oauth/openid/callback` or the value given in Open WebUI docs for your version).

- [ ] 2.3 **Terraform variables** (mirror `FORGEJO_OAUTH_*`): e.g. `OPENWEBUI_OAUTH_CLIENT_ID` and `OPEN_WEBUI_OAUTH_CLIENT_SECRET` (sensitive), passed into the container as the env vars Open WebUI requires for your chosen provider type (OIDC vs generic OAuth).

- [ ] 2.4 **Public URL env vars** on the container so links and OIDC redirects are correct behind Traefik (`WEBUI_URL` or equivalent for the image version).

## Phase 3 — VPN: droplet ↔ home desktop on a private subnet

Goal: the **droplet can open connections** to a **stable private IP** on the home side where the inference API listens (e.g. Ollama on `11434`), without exposing that port to the public Internet.

- [ ] 3.1 **Pick VPN technology** (implementation detail you must approve):
    - **Tailscale**: fast to operate, NAT traversal, ACLs; good if you accept a vendor control plane.
    - **Headscale** same but self-managed control plane
    - **Self-managed WireGuard**: full control; you manage keys, optional roaming, firewall rules on droplet and home router/PC.

- [ ] 3.2 **Topology**: one peer on the **DigitalOcean host** (host daemon or a small container with `cap_add` / `/dev/net/tun` if you containerize WireGuard) and one peer on the **home desktop** (or on the home router if you prefer a fixed hop).

- [ ] 3.3 **Addressing**: allocate a **private overlay subnet** (e.g. `10.x.y.0/24`) with static-ish IPs for “server” and “home inference”.

- [ ] 3.4 **Routing / DNS** (if needed): ensure the path from Open WebUI container to the inference host uses the VPN IP (e.g. `http://10.x.y.Z:11434`). If the inference stack only binds to localhost, rebind to the WireGuard/tailnet interface or put a small reverse proxy on the desktop.

- [ ] 3.5 **Firewall**:
    - **Droplet**: do not publish inference ports publicly; allow VPN interface only as needed.
    - **Home**: deny WAN access to Ollama; allow from VPN tail/keys only.

- [ ] 3.6 **Terraform vs manual**: decide what is **IaC** (e.g. `null_resource` + cloud-init, Ansible, or documented manual install on DO) vs **documented** steps on the Linux desktop. Full desktop automation will stay out of this repo.

## Phase 4 — Open WebUI ↔ inference backend

- [ ] 4.1 **Home desktop**: running **Ollama** with models sized for **16 GB VRAM**; confirm API binds only on VPN-accessible address.

- [ ] 4.2 **Open WebUI** admin: add connection to **OpenAI-compatible base URL** pointing at `http://<home-vpn-ip>:<port>` (or HTTPS if you add a local terminating proxy).

- [ ] 4.3 **Latency / timeouts**: expect higher RTT than local LAN; tune client timeouts if you use large contexts.

- [ ] 4.4 **Secrets**: if any API keys are used for remote providers, store via env or Docker secrets — align with how this repo handles other sensitive vars (`terraform.tfvars`, not committed).

## Phase 5 — Validation

- [ ] 5.1 **terraform plan** / apply; confirm container healthy, volume mounted, Traefik router shows green.

- [ ] 5.2 **https://<subdomain>.<HOST_NAME>** — login path works (OIDC or forwardAuth as chosen).

- [ ] 5.3 **Inside the Open WebUI container** (exec / debug): `curl` or equivalent to the **VPN IP:port** of the inference API succeeds.
23. End-to-end: prompt in UI → inference runs on home GPU → response returns.
