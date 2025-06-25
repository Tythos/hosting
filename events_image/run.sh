#!/bin/sh
set -e
curl --no-buffer -s --unix-socket /var/run/docker.sock http://localhost/events | jq -c '.'
