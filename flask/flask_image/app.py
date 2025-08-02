"""
"""

from random import randint
from flask import Flask, request
import logging

APP = Flask(__name__)
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

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
