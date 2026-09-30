#!/bin/bash
echo "===================================================="
echo "🚀 Starting Automated Centralized ELK Platform Setup"
echo "===================================================="
echo "🔄 Updating system packages..."
sudo apt-get update -y
if [ ! -f ".env" ]; then
echo "❌ Missing .env file. Create it before starting ELK."
exit 1
fi
echo "📦 Deploying ELK Stack Infrastructure Containers via Docker Compose..."
if [ -f "docker-compose.yml" ] || [ -f "docker/docker-compose.yml" ]; then
  sudo docker compose -f docker/docker-compose.yml up -d
  sleep 10
echo "🔍 Checking ELK container status..."
  sudo docker compose -f docker/docker-compose.yml ps
  running_count=$(sudo docker compose -f docker/docker-compose.yml ps --status running --services | wc -l)
if [ "$running_count" -eq 3 ]; then
echo "✅ All 3 ELK services are running."

else
echo "⚠️ Warning: Only $running_count of 3 ELK services are running."
fi

else
echo "⚠️ Note: Run script inside the folder containing docker/docker-compose.yml"
fi
echo "===================================================="
echo "🎉 ELK Centralized Automation Setup Sequence Complete!"
echo "===================================================="
