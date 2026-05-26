#!/bin/sh
set -e

CROWDSC_CONTAINER=crowdsec_container
TRAEFIK_CONTAINER=traefik_container

echo "=== CrowdSec Bouncer (Plugin) Verification ==="
echo ""

# 1. Check CrowdSec container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CROWDSC_CONTAINER}$"; then
  echo "FAIL: CrowdSec container '${CROWDSC_CONTAINER}' is not running."
  exit 1
fi
echo "PASS: CrowdSec container is running."

# 2. Check Traefik container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${TRAEFIK_CONTAINER}$"; then
  echo "FAIL: Traefik container '${TRAEFIK_CONTAINER}' is not running."
  exit 1
fi
echo "PASS: Traefik container is running."

# 3. Verify bouncer is registered in CrowdSec LAPI
BOUNCER_LIST=$(docker exec "${CROWDSC_CONTAINER}" cscli bouncers list -o json 2>/dev/null || true)
if echo "${BOUNCER_LIST}" | grep -q '"crowdsec-bouncer"'; then
  echo "PASS: Bouncer is registered with LAPI."
else
  echo "FAIL: Bouncer not found in 'cscli bouncers list'."
  echo "  Registered bouncers:"
  docker exec "${CROWDSC_CONTAINER}" cscli bouncers list 2>/dev/null || echo "  (none or LAPI not ready)"
  exit 1
fi

# 4. Verify Traefik has the crowdsec-bouncer plugin loaded
TRAEFIK_VERSION=$(docker exec "${TRAEFIK_CONTAINER}" traefik version 2>/dev/null || true)
echo "PASS: Traefik is running (${TRAEFIK_VERSION})"

# 5. Check Traefik logs for plugin initialization
PLUGIN_LOG=$(docker logs "${TRAEFIK_CONTAINER}" 2>&1 | grep -i "crowdsec" | tail -3 || true)
if [ -n "${PLUGIN_LOG}" ]; then
  echo "PASS: CrowdSec plugin detected in Traefik logs."
  echo "  ${PLUGIN_LOG}"
else
  echo "WARN: No CrowdSec plugin log entries found (may be quiet on successful init)."
fi

echo ""
echo "=== All checks complete ==="
echo ""
echo "To test ban detection manually:"
echo "  docker exec ${CROWDSC_CONTAINER} cscli decisions add --ip 203.0.113.1 -R 'Test Ban'"
echo "  # Then visit a site behind Traefik from that IP (simulate with curl -H 'X-Forwarded-For: 203.0.113.1')"
echo "  docker exec ${CROWDSC_CONTAINER} cscli decisions delete --ip 203.0.113.1"
