"""
"""

import flask
from gevent import pywsgi

APP = flask.Flask(__name__)

@APP.route("/")
def index():
    return "Hello, World!"

if __name__ == "__main__":
    pywsgi.WSGIServer(("0.0.0.0", 80), APP).serve_forever()
