"""
"""

import json
import time
import flask
import random
from gevent import pywsgi
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource

# Set up the tracer provider
resource = Resource.create({"service.name": "flask-app"})
trace.set_tracer_provider(TracerProvider(resource=resource))

# Set up the OTLP exporter
otlp_exporter = OTLPSpanExporter(endpoint="http://tempo_container:4318/v1/traces")
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

APP = flask.Flask(__name__)
FlaskInstrumentor().instrument_app(APP)

@APP.route("/")
def index():
    """
    """
    time.sleep(1)
    return "Hello, World!", 200, {"Content-Type": "text/plain"}

@APP.route("/users")
def get_users():
    """
    """
    time.sleep(2)
    return json.dumps({
        "users": [{
            "id": 1,
            "short_name": "Alice",
            "full_name": "Alice Smith",
            "email": "alice@example.com"
        }, {
            "id": 2,
            "short_name": "Bob",
            "full_name": "Bob Johnson",
            "email": "bob@example.com"
        }]
    }), 200, {"Content-Type": "application/json"}

@APP.route("/error")
def error():
    """
    """
    if random.random() < 0.5:
        raise Exception("Random error")
    return "No error", 200, {"Content-Type": "text/plain"}

def main():
    """
    """
    APP.run(host="0.0.0.0", port=80, debug=True)

if __name__ == "__main__":
    main()
