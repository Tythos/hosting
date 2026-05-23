resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = var.CF_ZONE_ID
  name        = "Block scanners and probes"
  description = "Custom WAF rules to block common scanners, probes, and known-bad traffic"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action = "block"
      expression = join(" or ", [
        for ua in [
          "zgrab", "masscan", "nmap", "nikto", "sqlmap",
          "nuclei", "wpscan", "openvas", "nessus", "acunetix",
          "netsparker", "faraday", "whatweb", "gobuster",
          "dirbuster", "bbot", "hydra", "python-httpx",
          "aiohttp", "jarm", "leakix", "censys", "shodan",
        ] : format("starts_with(lower(http.user_agent), %q)", ua)
      ])
      description = "Block known scanner tool user agents"
      enabled     = var.WAF_ENABLE_SCANNER_BLOCK
    },
    {
      action = "block"
      expression = join(" or ", [
        "http.user_agent contains \"scanner\"",
        "http.user_agent contains \"crawler\"",
        "http.user_agent contains \"spider\"",
        "http.user_agent contains \"Go-http-client\"",
        "http.user_agent contains \"go-http-client\"",
      ])
      description = "Block generic scanner patterns in user agents"
      enabled     = var.WAF_ENABLE_SCANNER_BLOCK
    },
    {
      action = "block"
      expression = join(" or ", [
        for path in [
          "/.env", "/.git", "/.aws", "/.ssh",
          "/vendor",
          "/wp-admin", "/wp-login", "/wp-content", "/wp-includes",
          "/xmlrpc.php",
          "/administrator",
          "/bitrix",
          "/composer.json", "/package.json",
          "/Dockerfile", "/docker-compose",
          "/Procfile",
          "/server-status", "/server-info",
          "/phpinfo.php", "/info.php", "/shell.php",
        ] : format("starts_with(http.request.uri.path, %q)", path)
      ])
      description = "Block common probe paths"
      enabled     = var.WAF_ENABLE_PROBE_BLOCK
    },
    {
      action = "block"
      expression = join(" or ", [
        for ext in [".sql", ".bak", ".swp", ".old", ".save", ".orig", ".dist"] : format("ends_with(http.request.uri.path, %q)", ext)
      ])
      description = "Block sensitive file extensions"
      enabled     = var.WAF_ENABLE_PROBE_BLOCK
    }
  ]
}

resource "cloudflare_ruleset" "rate_limit" {
  zone_id     = var.CF_ZONE_ID
  name        = "Rate limit aggressive scanners"
  description = "Rate limit IPs that make excessive requests, indicating automated scanning"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [
    {
      action = "block"
      ratelimit = {
        characteristics     = ["cf.colo.id", "ip.src"]
        period              = 10
        requests_per_period = 20
        mitigation_timeout  = 10
        requests_to_origin  = false
      }
      expression  = "not cf.client.bot"
      description = "Block IPs exceeding 100 requests in 60 seconds"
      enabled     = var.WAF_ENABLE_RATE_LIMIT
    }
  ]
}
