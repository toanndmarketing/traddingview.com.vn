#!/bin/bash
# Phân tích traffic trên Host Nginx
LOG_FILE="/var/log/nginx/access.log"

echo "=== TOP 20 REAL IPs (Dựa trên header Cloudflare) ==="
grep -oP 'cf_ip="\K[^"]+' $LOG_FILE | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== TOP 10 Countries ==="
grep -oP 'cf_country="\K[^"]+' $LOG_FILE | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== Top 20 User Agents (Tìm bot/tools) ==="
# Lấy phần User Agent (thường nằm trong ngoặc kép thứ 6 hoặc sau referer)
awk -F'"' '{print $6}' $LOG_FILE | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== IPs spam nhiều request nhất trong 5 phút qua ==="
# Lấy các request trong 5 phút gần đây (giả sử định dạng log chuẩn)
current_time=$(date +%d/%b/%Y:%H:%M --date='5 minutes ago')
sed -n "/$current_time/,\$p" $LOG_FILE | grep -oP 'cf_ip="\K[^"]+' | sort | uniq -c | sort -rn | head -15

echo ""
echo "=== Phân tích hành vi onsite thấp (Spam visit) ==="
# Tìm các IP chỉ vào 1 URL rồi biến mất ngay (Single page session)
# (Cần log kỹ hơn để tính giây, hiện tại ta check số request/IP cực thấp nhưng liên tục)
grep -oP 'cf_ip="\K[^"]+' $LOG_FILE | sort | uniq -c | awk '$1 < 3 {print $2}' | tail -n 20
