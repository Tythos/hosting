# Grafana dashboards (manual import)

These JSON files are **not** applied by Terraform. They assume you already run Grafana with a **Prometheus** datasource (this repo’s Prometheus scrapes Traefik and `node_exporter`).

**Import:** Grafana → **Dashboards** → **New** → **Import** → upload the JSON → select your existing Prometheus when prompted.

| File | Purpose |
|------|---------|
| `openwebui-chat-red-use.json` | **RED** (rate / errors / latency) for Open WebUI’s public route via Traefik `chat@docker`; **USE**-style host signals from `node_exporter`. |

After import, if panels are empty, check Prometheus for the exact Traefik labels (e.g. `service="chat@docker"`) with **Explore**.
