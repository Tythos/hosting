#!/usr/bin/env python3
"""
Simple Flask application that generates traces for testing the observability stack.
"""

import time
import random
import logging
from flask import Flask, jsonify, request
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configure OTLP exporter
otlp_exporter = OTLPSpanExporter(
    endpoint="http://tempo_container:4318/v1/traces",
    headers={}
)

# Add BatchSpanProcessor to the tracer
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

# Create Flask app
app = Flask(__name__)

# Instrument Flask and Requests
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

@app.route('/')
def home():
    """Home endpoint that generates a simple trace."""
    with tracer.start_as_current_span("home_request") as span:
        span.set_attribute("endpoint", "/")
        span.set_attribute("method", "GET")
        
        # Simulate some work
        time.sleep(random.uniform(0.1, 0.5))
        
        return jsonify({
            "message": "Hello from Trace Test App!",
            "timestamp": time.time(),
            "trace_id": format(span.get_span_context().trace_id, '032x')
        })

@app.route('/slow')
def slow_endpoint():
    """Slow endpoint that generates a longer trace."""
    with tracer.start_as_current_span("slow_request") as span:
        span.set_attribute("endpoint", "/slow")
        span.set_attribute("method", "GET")
        
        # Simulate slow processing
        time.sleep(random.uniform(1, 3))
        
        # Create a child span
        with tracer.start_as_current_span("slow_processing") as child_span:
            child_span.set_attribute("processing_type", "heavy_computation")
            time.sleep(random.uniform(0.5, 1.5))
        
        return jsonify({
            "message": "Slow operation completed",
            "duration": "1-3 seconds",
            "trace_id": format(span.get_span_context().trace_id, '032x')
        })

@app.route('/error')
def error_endpoint():
    """Endpoint that generates an error trace."""
    with tracer.start_as_current_span("error_request") as span:
        span.set_attribute("endpoint", "/error")
        span.set_attribute("method", "GET")
        span.set_attribute("error", True)
        
        # Simulate some work before error
        time.sleep(random.uniform(0.1, 0.3))
        
        # Record an error
        span.record_exception(Exception("Simulated error for testing"))
        
        return jsonify({
            "error": "Simulated error for testing",
            "trace_id": format(span.get_span_context().trace_id, '032x')
        }), 500

@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({"status": "healthy", "service": "trace-test-app"})

@app.route('/metrics')
def metrics():
    """Basic metrics endpoint for Prometheus scraping."""
    return jsonify({
        "requests_total": 0,  # This would be incremented in a real app
        "requests_duration_seconds": 0.0,
        "errors_total": 0
    })

if __name__ == '__main__':
    logger.info("Starting Trace Test App...")
    app.run(host='0.0.0.0', port=5000, debug=False) 