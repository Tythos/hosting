# requirements.txt
"""
flask==2.3.3
opentelemetry-api==1.20.0
opentelemetry-sdk==1.20.0
opentelemetry-exporter-otlp-proto-grpc==1.20.0
opentelemetry-instrumentation-flask==0.41b0
opentelemetry-instrumentation-requests==0.41b0
opentelemetry-instrumentation-urllib3==0.41b0
requests==2.31.0
"""

# app.py
from flask import Flask, request, jsonify
import requests
import time
import random
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
import os

# Configure OpenTelemetry
resource = Resource.create({
    "service.name": os.getenv("OTEL_SERVICE_NAME", "flask-test-app"),
    "service.version": "1.0.0",
    "deployment.environment": os.getenv("OTEL_ENVIRONMENT", "test")
})

# Set up tracer provider
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer(__name__)

# Configure OTLP exporter
otlp_exporter = OTLPSpanExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://tempo:4317"),
    insecure=True
)

# Add span processor
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Create Flask app
app = Flask(__name__)

# Auto-instrument Flask and requests
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

@app.route('/')
def home():
    """Simple home endpoint with basic tracing"""
    with tracer.start_as_current_span("home_handler") as span:
        span.set_attribute("endpoint", "home")
        span.set_attribute("method", request.method)
        
        # Simulate some work
        time.sleep(random.uniform(0.1, 0.3))
        
        return jsonify({
            "message": "Flask OTLP Test App",
            "trace_id": format(span.get_span_context().trace_id, '032x'),
            "endpoints": ["/", "/api/users", "/api/slow", "/api/error", "/api/chain"]
        })

@app.route('/api/users')
def get_users():
    """Endpoint that demonstrates database-like operations"""
    with tracer.start_as_current_span("get_users") as span:
        span.set_attribute("operation", "database.query")
        span.set_attribute("table", "users")
        
        # Simulate database query
        with tracer.start_as_current_span("db.query") as db_span:
            db_span.set_attribute("db.system", "postgresql")
            db_span.set_attribute("db.statement", "SELECT * FROM users LIMIT 10")
            time.sleep(random.uniform(0.05, 0.15))
            
        users = [
            {"id": 1, "name": "Alice", "email": "alice@example.com"},
            {"id": 2, "name": "Bob", "email": "bob@example.com"},
            {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
        ]
        
        span.set_attribute("result.count", len(users))
        return jsonify({"users": users})

@app.route('/api/slow')
def slow_endpoint():
    """Intentionally slow endpoint to test performance tracing"""
    with tracer.start_as_current_span("slow_operation") as span:
        span.set_attribute("operation.type", "heavy_computation")
        
        # Simulate multiple slow operations
        operations = ["data_processing", "file_io", "network_call"]
        
        for i, op in enumerate(operations):
            with tracer.start_as_current_span(f"step_{i+1}_{op}") as step_span:
                step_span.set_attribute("step.name", op)
                step_span.set_attribute("step.number", i + 1)
                
                # Random delay to simulate work
                delay = random.uniform(0.5, 1.0)
                time.sleep(delay)
                step_span.set_attribute("duration_ms", delay * 1000)
        
        return jsonify({
            "message": "Slow operation completed",
            "operations": operations,
            "total_steps": len(operations)
        })

@app.route('/api/error')
def error_endpoint():
    """Endpoint that demonstrates error tracing"""
    with tracer.start_as_current_span("error_prone_operation") as span:
        span.set_attribute("operation", "risky_business")
        
        # Randomly succeed or fail
        if random.random() < 0.3:  # 30% chance of success
            span.set_attribute("result", "success")
            return jsonify({"message": "Operation succeeded!"})
        else:
            # Record the error in the span
            span.set_attribute("result", "error")
            span.set_attribute("error.type", "SimulatedError")
            span.record_exception(Exception("Simulated failure"))
            span.set_status(trace.Status(trace.StatusCode.ERROR, "Operation failed"))
            
            return jsonify({"error": "Simulated failure occurred"}), 500

@app.route('/api/chain')
def chain_requests():
    """Endpoint that makes calls to other services to demonstrate distributed tracing"""
    with tracer.start_as_current_span("service_chain") as span:
        span.set_attribute("operation", "multi_service_call")
        
        results = []
        
        # Call our own endpoints to simulate service-to-service calls
        base_url = request.host_url.rstrip('/')
        
        # Call users endpoint
        with tracer.start_as_current_span("call_users_service") as call_span:
            call_span.set_attribute("http.url", f"{base_url}/api/users")
            call_span.set_attribute("http.method", "GET")
            
            try:
                response = requests.get(f"{base_url}/api/users", timeout=5)
                call_span.set_attribute("http.status_code", response.status_code)
                results.append({"service": "users", "status": "success", "data": response.json()})
            except Exception as e:
                call_span.record_exception(e)
                call_span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
                results.append({"service": "users", "status": "error", "error": str(e)})
        
        # Call external API (httpbin for testing)
        with tracer.start_as_current_span("call_external_api") as ext_span:
            ext_span.set_attribute("http.url", "https://httpbin.org/delay/1")
            ext_span.set_attribute("http.method", "GET")
            ext_span.set_attribute("service.external", True)
            
            try:
                response = requests.get("https://httpbin.org/delay/1", timeout=10)
                ext_span.set_attribute("http.status_code", response.status_code)
                results.append({"service": "httpbin", "status": "success"})
            except Exception as e:
                ext_span.record_exception(e)
                ext_span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
                results.append({"service": "httpbin", "status": "error", "error": str(e)})
        
        span.set_attribute("calls.total", len(results))
        span.set_attribute("calls.successful", sum(1 for r in results if r["status"] == "success"))
        
        return jsonify({
            "message": "Chain of service calls completed",
            "results": results,
            "trace_id": format(span.get_span_context().trace_id, '032x')
        })

@app.route('/health')
def health_check():
    """Simple health check endpoint"""
    return jsonify({"status": "healthy", "service": "flask-test-app"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)