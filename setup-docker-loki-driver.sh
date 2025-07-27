#!/bin/bash

# Install Loki Docker Driver
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions

# Create Docker daemon configuration
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://loki_container:3100/loki/api/v1/push",
    "loki-pipeline-stages": "[{\"json\":{\"expressions\":{\"log\":\"log\",\"stream\":\"stream\",\"time\":\"time\"}}}]",
    "loki-relabel-config": "[{\"source_labels\":[\"__docker_container_name__\"],\"regex\":\"loki_container\",\"action\":\"drop\"}]"
  }
}
EOF

# Restart Docker daemon
systemctl restart docker

echo "Docker Loki driver configured. You may need to restart containers for the new logging driver to take effect." 