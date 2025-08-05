"""
"""

import os
import json
import resend
from random import randint
from flask import Flask, request
import logging

APP = Flask(__name__)
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

@APP.route("/env", methods=["GET"])
def get_env():
    """
    """
    reject = [
        "HOSTNAME",
        "GPG_KEY",
        "PYTHON_SHA256",
        "RESEND_API_KEY"
    ]
    env = {}
    for k, v in os.environ.items():
        if k not in reject:
            env[k] = v
    return json.dumps(env, indent=4), 200, {"Content-Type": "application/json"}

@APP.route("/email", methods=["POST"])
def post_email():
    """
    """
    if False:
        resend.api_key = os.environ.get("RESEND_API_KEY")
        email = {}
        email["from"] = "notifications@tythos.io"
        email["to"] = "bekirkpatrick@proton.me"
        email["subject"] = "Farewell, Cruel World"
        email["html"] = "<p>This is a paragraph.</p><p>Isn't it lovely?</p>"
        result = resend.Emails.send(email)
        return json.dumps(result, indent=4), 200, {"Content-Type": "application/json"}
    return "Forbidden", 403, {"Content-Type": "text/plain"}

@APP.route("/")
def index():
    """
    """
    return "OK", 200, {"Content-Type": "text/plain"}

@APP.route("/rolldice")
def roll_dice():
    """
    """
    player = request.args.get('player', default=None, type=str)
    result = str(randint(1, 6))
    if player:
        LOGGER.warning("%s is rolling the dice: %s", player, result)
    else:
        LOGGER.warning("Anonymous player is rolling the dice: %s", result)
    return result
