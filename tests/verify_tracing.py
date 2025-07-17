#!/usr/bin/env python3
"""
Comprehensive test script to verify the tracing setup is working properly.

Run with:
docker run --rm --network=hosting_network -v "$(pwd)":/app -w /app python:3.9-slim sh -c "pip install -q requests && python tests/verify_tracing.py"
"""

import requests
import time
import json
import os
from datetime import datetime, timedelta

def check_service_health(service_name, url, expected_status=200):
    """Check if a service is healthy."""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == expected_status:
            print(f"✅ {service_name} is healthy")
            return True
        else:
            print(f"❌ {service_name} returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ {service_name} is not accessible: {e}")
        return False

def check_tempo_endpoints():
    """Check Tempo endpoints."""
    base_url = "http://tempo_container:3200"
    
    print("\n🔍 Checking Tempo endpoints...")
    
    # Check ready endpoint
    ready_ok = check_service_health("Tempo Ready", f"{base_url}/ready")
    
    # Check metrics endpoint
    metrics_ok = check_service_health("Tempo Metrics", f"{base_url}/metrics")
    
    # Check search endpoint
    search_ok = check_service_health("Tempo Search", f"{base_url}/api/search")
    
    return ready_ok and metrics_ok and search_ok

def check_grafana_datasources():
    """Check if Grafana has the correct datasources configured."""
    base_url = "http://grafana_container:3000"
    
    print("\n🔍 Checking Grafana datasources...")
    
    # Note: This would require admin credentials to check datasources
    # For now, we'll just check if Grafana is accessible
    grafana_ok = check_service_health("Grafana", f"{base_url}/api/health")
    
    if grafana_ok:
        print("✅ Grafana is accessible")
        print("   You can manually verify datasources at: https://grafana.{host}/datasources")
    else:
        print("❌ Grafana is not accessible")
    
    return grafana_ok

def generate_test_traces():
    """Generate test traces using the trace test app."""
    base_url = "https://trace-test.tythos.io"  # Adjust based on your domain
    
    print("\n🔍 Generating test traces...")
    
    try:
        # Test basic endpoint
        print("   Testing / endpoint...")
        response = requests.get(f"{base_url}/", timeout=10, verify=False)
        if response.status_code == 200:
            data = response.json()
            trace_id = data.get('trace_id', 'unknown')
            print(f"   ✅ Generated trace with ID: {trace_id}")
        else:
            print(f"   ❌ Failed to generate trace: {response.status_code}")
            return False
        
        # Test slow endpoint
        print("   Testing /slow endpoint...")
        response = requests.get(f"{base_url}/slow", timeout=15, verify=False)
        if response.status_code == 200:
            data = response.json()
            trace_id = data.get('trace_id', 'unknown')
            print(f"   ✅ Generated slow trace with ID: {trace_id}")
        else:
            print(f"   ❌ Failed to generate slow trace: {response.status_code}")
        
        # Test error endpoint
        print("   Testing /error endpoint...")
        response = requests.get(f"{base_url}/error", timeout=10, verify=False)
        if response.status_code == 500:
            data = response.json()
            trace_id = data.get('trace_id', 'unknown')
            print(f"   ✅ Generated error trace with ID: {trace_id}")
        else:
            print(f"   ❌ Failed to generate error trace: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error generating traces: {e}")
        return False

def check_traces_in_tempo():
    """Check if traces are visible in Tempo."""
    base_url = "http://tempo_container:3200"
    
    print("\n🔍 Checking for traces in Tempo...")
    
    try:
        # Wait a bit for traces to be ingested
        print("   Waiting 10 seconds for traces to be ingested...")
        time.sleep(10)
        
        # Check search endpoint
        response = requests.get(f"{base_url}/api/search", timeout=10)
        if response.status_code == 200:
            data = response.json()
            traces = data.get('traces', [])
            print(f"   ✅ Found {len(traces)} traces in Tempo")
            
            if traces:
                for trace in traces[:3]:  # Show first 3 traces
                    trace_id = trace.get('traceID', 'unknown')
                    service_name = trace.get('rootServiceName', 'unknown')
                    print(f"      - Trace ID: {trace_id}, Service: {service_name}")
            
            return len(traces) > 0
        else:
            print(f"   ❌ Failed to search traces: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"   ❌ Error checking traces: {e}")
        return False

def check_prometheus_metrics():
    """Check if Tempo metrics are available in Prometheus."""
    base_url = "http://prometheus_container:9090"
    
    print("\n🔍 Checking Tempo metrics in Prometheus...")
    
    try:
        # Query for Tempo metrics
        query = 'up{job="tempo"}'
        response = requests.get(f"{base_url}/api/v1/query", params={'query': query}, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            result = data.get('data', {}).get('result', [])
            
            if result:
                print("   ✅ Tempo metrics found in Prometheus")
                for metric in result:
                    labels = metric.get('metric', {})
                    value = metric.get('value', [])
                    print(f"      - {labels}: {value[1] if len(value) > 1 else 'unknown'}")
                return True
            else:
                print("   ❌ No Tempo metrics found in Prometheus")
                return False
        else:
            print(f"   ❌ Failed to query Prometheus: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"   ❌ Error checking Prometheus metrics: {e}")
        return False

def main():
    """Main verification function."""
    print("🚀 Starting comprehensive tracing verification...")
    print(f"📅 Test started at: {datetime.now()}")
    
    # Check basic service health
    tempo_ok = check_tempo_endpoints()
    grafana_ok = check_grafana_datasources()
    
    # Generate test traces
    traces_generated = generate_test_traces()
    
    # Check if traces are visible
    traces_visible = check_traces_in_tempo()
    
    # Check Prometheus metrics
    metrics_ok = check_prometheus_metrics()
    
    # Summary
    print("\n" + "="*50)
    print("📊 VERIFICATION SUMMARY")
    print("="*50)
    
    print(f"Tempo Service: {'✅ OK' if tempo_ok else '❌ FAILED'}")
    print(f"Grafana Service: {'✅ OK' if grafana_ok else '❌ FAILED'}")
    print(f"Trace Generation: {'✅ OK' if traces_generated else '❌ FAILED'}")
    print(f"Trace Visibility: {'✅ OK' if traces_visible else '❌ FAILED'}")
    print(f"Prometheus Metrics: {'✅ OK' if metrics_ok else '❌ FAILED'}")
    
    if all([tempo_ok, grafana_ok, traces_generated, traces_visible, metrics_ok]):
        print("\n🎉 All checks passed! Your tracing setup is working correctly.")
        print("\n📋 Next steps:")
        print("   1. Visit https://grafana.{your-domain} to view traces")
        print("   2. Go to Explore → Tempo to search for traces")
        print("   3. Create dashboards to visualize trace data")
    else:
        print("\n⚠️  Some checks failed. Please review the output above.")
        print("\n🔧 Troubleshooting tips:")
        print("   1. Check container logs: docker logs tempo_container")
        print("   2. Verify network connectivity between containers")
        print("   3. Check Grafana datasource configuration")
        print("   4. Ensure Traefik is properly configured for tracing")

if __name__ == "__main__":
    main() 