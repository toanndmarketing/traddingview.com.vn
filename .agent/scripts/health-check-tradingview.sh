#!/bin/bash
# Health Check Script cho Tradingview.com.vn Ghost CMS
# Kiểm tra toàn diện: Database, Containers, Resources, Logs, Performance

set -e

echo "========================================="
echo "🔍 HEALTH CHECK - TRADINGVIEW.COM.VN"
echo "========================================="
echo ""

# 1. Database Check
echo "📊 DATABASE STATUS"
echo "-------------------"
docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "
SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size_MB', table_rows 
FROM information_schema.TABLES 
WHERE table_schema = 'ghostproduction' 
ORDER BY 2 DESC 
LIMIT 10;
" 2>&1 | grep -v Warning

echo ""
docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "
SELECT COUNT(*) as 'Actions_Count' FROM actions;
" 2>&1 | grep -v Warning

echo ""
echo ""

# 2. Containers Status
echo "🐳 CONTAINERS STATUS"
echo "--------------------"
cd /home/tradingview.com.vn && docker compose ps
echo ""
echo ""

# 3. System Resources
echo "💾 SYSTEM RESOURCES"
echo "-------------------"
echo "DISK:"
df -h | grep '/$'
echo ""
echo "RAM:"
free -h | grep Mem
echo ""
echo "CONNECTIONS:"
ss -ant | grep ESTAB | wc -l
echo ""
echo ""

# 4. Recent Errors
echo "⚠️  RECENT ERRORS (Last 1 hour)"
echo "--------------------------------"
cd /home/tradingview.com.vn && docker compose logs --tail=100 --since 1h | grep -Ei 'error|warn|503|500|fail' || echo "✅ Clean - No errors found"
echo ""
echo ""

# 5. Performance Test
echo "⚡ PERFORMANCE TEST"
echo "-------------------"
echo -n "Homepage Response Time: "
curl -s -o /dev/null -w '%{time_total}s\n' http://localhost:3005
echo ""

echo "========================================="
echo "✅ HEALTH CHECK COMPLETED"
echo "========================================="
