"""
"""

import flask
from gevent import pywsgi
from opentelemetry import (trace, sdk)

APP = flask.Flask(__name__)
trace.set_tracer_provider(sdk.trace.TracerProvider(resource=sdk.resources.Resource(
    "service.name": "flask-test-app",
    "service.version": "1.0.0",
    "deployment.environment": "test"
)))
tracer = trace.get_tracer(__name__)

@APP.route("/")
def index():
    with tracer.start_as_current_span("index") as span:
        span.set_attribute("endpoint", "home")
        span.set_attribute("method", flask.request.method)
        return "Hello, World!"

if __name__ == "__main__":
    pywsgi.WSGIServer(("0.0.0.0", 80), APP).serve_forever()
