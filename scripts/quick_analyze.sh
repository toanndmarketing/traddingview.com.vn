#!/bin/bash
# Quick Traffic Analysis - Last 10000 lines only
ACCESS_LOG="/var/log/nginx/access.log"

echo "=== TOP 30 IPs (Last 10000 requests) ==="
tail -10000 $ACCESS_LOG | awk '{print $1}' | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== Countries ==="
tail -10000 $ACCESS_LOG | grep -oP 'cf_country="\K[^"]+' | sort | uniq -c | sort -rn | head -15

echo ""
echo "=== HTTP Status ==="
tail -10000 $ACCESS_LOG | awk '{print $9}' | sort | uniq -c | sort -rn

echo ""
echo "=== Bots/Crawlers ==="
tail -10000 $ACCESS_LOG | grep -iE 'bot|crawl|spider' | awk '{print $1}' | sort | uniq -c | sort -rn | head -15

echo "DONE"
