#!/bin/bash
# Rebuild and restart Ghost containers
cd /home/tradingview.com.vn
echo "Starting Docker Compose rebuild..."
docker compose up -d --build
echo "Rebuild complete."
