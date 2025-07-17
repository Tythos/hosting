#!/bin/bash

# Deploy and verify tracing setup
set -e

echo "🚀 Deploying tracing infrastructure..."

# Apply Terraform configuration
echo "📦 Applying Terraform configuration..."
terraform apply -auto-approve

# Wait for containers to be ready
echo "⏳ Waiting for containers to be ready..."
sleep 30

# Check container status
echo "🔍 Checking container status..."
docker ps --filter "name=tempo_container" --filter "name=grafana_container" --filter "name=trace_test_app_container"

# Run verification tests
echo "🧪 Running verification tests..."
docker run --rm --network=hosting_network -v "$(pwd)":/app -w /app python:3.9-slim sh -c "pip install -q requests && python tests/verify_tracing.py"

echo "✅ Deployment complete!"
echo ""
echo "📋 Access URLs:"
echo "   - Grafana: https://grafana.$(terraform output -raw HOST_NAME)"
echo "   - Trace Test App: https://trace-test.$(terraform output -raw HOST_NAME)"
echo "   - Traefik Dashboard: https://dashboard.$(terraform output -raw HOST_NAME)"
echo ""
echo "🔍 To view traces in Grafana:"
echo "   1. Go to Explore"
echo "   2. Select Tempo datasource"
echo "   3. Search for traces by service name or trace ID"
echo ""
echo "📊 To import the tracing dashboard:"
echo "   1. Go to Dashboards > Import"
echo "   2. Upload dashboards/tracing_dashboard.json" 