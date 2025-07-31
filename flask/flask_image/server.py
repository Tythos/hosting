"""
"""

import json
import time
import flask
import random
from gevent import pywsgi
#from opentelemetry import (trace, sdk)

APP = flask.Flask(__name__)
#trace.set_tracer_provider(sdk.trace.TracerProvider(resource=sdk.resources.Resource(
#    "service.name": "flask-test-app",
#    "service.version": "1.0.0",
#    "deployment.environment": "test"
#)))
#tracer = trace.get_tracer(__name__)

@APP.route("/")
def index():
    """
    """
#    with tracer.start_as_current_span("index") as span:
#        span.set_attribute("endpoint", "home")
#        span.set_attribute("method", flask.request.method)
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

if __name__ == "__main__":
    pywsgi.WSGIServer(("0.0.0.0", 80), APP).serve_forever()
