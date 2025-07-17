#!/bin/bash

# Health check script for tracing infrastructure
set -e

echo "🏥 Checking tracing infrastructure health..."

# Check Tempo
echo "🔍 Checking Tempo..."
if curl -f -s http://tempo_container:3200/ready > /dev/null; then
    echo "✅ Tempo is healthy"
else
    echo "❌ Tempo is not responding"
    exit 1
fi

# Check Grafana
echo "🔍 Checking Grafana..."
if curl -f -s http://grafana_container:3000/api/health > /dev/null; then
    echo "✅ Grafana is healthy"
else
    echo "❌ Grafana is not responding"
    exit 1
fi

# Check Trace Test App
echo "🔍 Checking Trace Test App..."
if curl -f -s http://trace_test_app_container:5000/health > /dev/null; then
    echo "✅ Trace Test App is healthy"
else
    echo "❌ Trace Test App is not responding"
    exit 1
fi

# Check Prometheus for Tempo metrics
echo "🔍 Checking Tempo metrics in Prometheus..."
if curl -f -s "http://prometheus_container:9090/api/v1/query?query=up{job=\"tempo\"}" | grep -q '"result":\[{"metric"' 2>/dev/null; then
    echo "✅ Tempo metrics are available in Prometheus"
else
    echo "❌ Tempo metrics not found in Prometheus"
    exit 1
fi

echo "🎉 All tracing components are healthy!" 