#!/bin/bash
echo "===================================================="
echo "🚀 Starting Automated Centralized ELK Platform Setup"
echo "===================================================="
echo "🔄 Updating system packages..."
sudo apt-get update -y
echo "📦 Deploying ELK Stack Infrastructure Containers via Docker Compose..."
if [ -f "docker-compose.yml" ] || [ -f "docker/docker-compose.yml" ]; then
  sudo docker compose up -d
else
  echo "⚠️ Note: Run script inside the folder containing docker-compose.yml"
fi
echo "===================================================="
echo "🎉 ELK Centralized Automation Setup Sequence Complete!"
echo "===================================================="
