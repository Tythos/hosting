#!/usr/bin/env python3
"""
Test script to generate traces for the Flask OTEL application
Run this to create various trace patterns for testing Tempo
"""

import requests
import time
import json
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

def make_request(method, url, **kwargs):
    """Make HTTP request with error handling"""
    try:
        response = requests.request(method, url, timeout=10, **kwargs)
        return {
            'url': url,
            'status': response.status_code,
            'success': response.ok,
            'data': response.json() if response.ok else None,
            'error': None
        }
    except Exception as e:
        return {
            'url': url,
            'status': None,
            'success': False,
            'data': None,
            'error': str(e)
        }

def test_basic_endpoints(base_url):
    """Test basic endpoints to generate simple traces"""
    print("🧪 Testing basic endpoints...")
    
    endpoints = [
        ('GET', f'{base_url}/health'),
        ('GET', f'{base_url}/metrics'),
        ('GET', f'{base_url}/subscribers'),
    ]
    
    results = []
    for method, url in endpoints:
        result = make_request(method, url)
        results.append(result)
        print(f"  {method} {url}: {'✅' if result['success'] else '❌'} ({result['status']})")
        time.sleep(0.5)
    
    return results

def test_broadcast_workflow(base_url):
    """Test the complete broadcast workflow"""
    print("\n📡 Testing broadcast workflow...")
    
    # Add subscribers
    subscribers = [
        {"id": "test_sub_1", "name": "Alpha Subscriber"},
        {"id": "test_sub_2", "name": "Beta Subscriber"},
        {"id": "test_sub_3", "name": "Gamma Subscriber"}
    ]
    
    for sub in subscribers:
        result = make_request('POST', f'{base_url}/subscribe', json=sub)
        print(f"  Subscribe {sub['name']}: {'✅' if result['success'] else '❌'}")
        time.sleep(0.2)
    
    # Send messages
    messages = [
        {"id": "msg_001", "type": "info", "content": "System initialization complete"},
        {"id": "msg_002", "type": "alert", "content": "High memory usage detected"},
        {"id": "msg_003", "type": "update", "content": "Configuration updated"}
    ]
    
    for msg in messages:
        result = make_request('POST', f'{base_url}/broadcast', json=msg)
        print(f"  Broadcast {msg['type']}: {'✅' if result['success'] else '❌'}")
        time.sleep(0.3)  # Give time for message processing
    
    # Wait for messages to be processed
    print("  ⏳ Waiting for message processing...")
    time.sleep(2)

def test_automated_scenario(base_url):
    """Test the automated scenario endpoint"""
    print("\n🤖 Testing automated scenario...")
    
    result = make_request('GET', f'{base_url}/test-scenario')
    if result['success']:
        data = result['data']
        print(f"  ✅ Scenario executed: {data['subscribers_added']} subscribers, {data['messages_queued']} messages")
    else:
        print(f"  ❌ Scenario failed: {result['error']}")
    
    time.sleep(2)  # Wait for processing

def test_load_generation(base_url):
    """Test load generation endpoint"""
    print("\n⚡ Testing load generation...")
    
    for i in range(3):
        result = make_request('GET', f'{base_url}/generate-load')
        if result['success']:
            data = result['data']
            print(f"  ✅ Load batch {i+1}: {data['messages_queued']} messages generated")
        else:
            print(f"  ❌ Load batch {i+1} failed: {result['error']}")
        time.sleep(1)

def test_concurrent_requests(base_url):
    """Test concurrent requests to generate complex trace patterns"""
    print("\n🔀 Testing concurrent requests...")
    
    # Define concurrent operations
    operations = [
        ('GET', f'{base_url}/metrics'),
        ('POST', f'{base_url}/subscribe', {'json': {"id": "concurrent_sub_1", "name": "Concurrent Sub 1"}}),
        ('POST', f'{base_url}/broadcast', {'json': {"id": "concurrent_msg_1", "type": "concurrent", "content": "Concurrent message 1"}}),
        ('GET', f'{base_url}/subscribers'),
        ('POST', f'{base_url}/subscribe', {'json': {"id": "concurrent_sub_2", "name": "Concurrent Sub 2"}}),
        ('POST', f'{base_url}/broadcast', {'json': {"id": "concurrent_msg_2", "type": "concurrent", "content": "Concurrent message 2"}}),
        ('GET', f'{base_url}/generate-load'),
    ]
    
    # Execute concurrently
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = []
        for method, url, *args in operations:
            kwargs = args[0] if args else {}
            future = executor.submit(make_request, method, url, **kwargs)
            futures.append((future, f"{method} {url}"))
        
        # Collect results
        for future, description in futures:
            result = future.result()
            print(f"  {description}: {'✅' if result['success'] else '❌'}")

def test_request_chains(base_url):
    """Test request chains that create trace hierarchies"""
    print("\n🔗 Testing request chains...")
    
    result = make_request('GET', f'{base_url}/chain-requests')
    if result['success']:
        data = result['data']
        print(f"  ✅ Chain completed: {len(data.get('operations', []))} operations")
    else:
        print(f"  ❌ Chain failed: {result['error']}")

def main():
    # Configuration
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:5000"
    
    print(f"🚀 Starting trace generation tests against {base_url}")
    print("=" * 60)
    
    # Check if service is available
    try:
        health_result = make_request('GET', f'{base_url}/health')
        if not health_result['success']:
            print(f"❌ Service not available at {base_url}")
            sys.exit(1)
        print(f"✅ Service is healthy")
    except Exception as e:
        print(f"❌ Cannot connect to service: {e}")
        sys.exit(1)
    
    # Run test scenarios
    try:
        test_basic_endpoints(base_url)
        test_broadcast_workflow(base_url)
        test_automated_scenario(base_url)
        test_load_generation(base_url)
        test_concurrent_requests(base_url)
        test_request_chains(base_url)
        
        print("\n" + "=" * 60)
        print("🎉 All tests completed!")
        print("\n📊 Check your traces in:")
        print("   - Grafana: http://localhost:3000 (admin/admin)")
        print("   - Tempo: http://localhost:3200")
        print("\n💡 Try searching for traces with:")
        print("   - Service: flask-test-app")
        print("   - Operations: GET /broadcast, POST /subscribe, etc.")
        
    except KeyboardInterrupt:
        print("\n\n⏹️  Test interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Test failed with error: {e}")

if __name__ == "__main__":
    main()