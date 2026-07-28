#!/bin/bash

# Configuration
CONTAINER_NAME="ghost-mysql"
DB_USER="ghost-814"
DB_PASS="Tr@dingV!ew_User_2025!"
DB_NAME="ghostproduction"

echo "========================================="
echo "🚀 DATABASE OPTIMIZATION - TRADINGVIEW"
echo "========================================="

# 1. Cleanup old actions (older than 60 days)
echo "🧹 Cleaning up actions older than 60 days..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p"$DB_PASS" $DB_NAME -e "DELETE FROM actions WHERE created_at < DATE_SUB(NOW(), INTERVAL 60 DAY);"

# 2. Optimize large tables
echo "⚡ Optimizing tables: posts, actions, mobiledoc_revisions..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p"$DB_PASS" $DB_NAME -e "OPTIMIZE TABLE posts, actions, mobiledoc_revisions;"

# 3. Docker Cleanup
echo "🐳 Pruning Docker system..."
docker system prune -f

# 4. Restart Services to refresh
echo "🔄 Restarting Ghost services..."
cd /home/tradingview.com.vn && docker compose restart

echo "========================================="
echo "✅ OPTIMIZATION COMPLETED"
echo "========================================="
