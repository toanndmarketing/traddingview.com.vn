#!/bin/bash
# Quick Traffic Analysis - Run on host
ACCESS_LOG="/var/log/nginx/access.log"

echo "=== TOP 30 IPs (Last 5000 requests) ==="
tail -5000 $ACCESS_LOG | awk '{print $1}' | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== Countries (Last 5000) ==="
tail -5000 $ACCESS_LOG | grep -oP 'cf_country="\K[^"]+' | sort | uniq -c | sort -rn | head -15

echo ""
echo "=== HTTP Status (Last 5000) ==="
tail -5000 $ACCESS_LOG | awk '{print $9}' | sort | uniq -c | sort -rn

echo ""
echo "=== TOP URLs (Last 5000) ==="
tail -5000 $ACCESS_LOG | awk '{print $7}' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== Bots/Crawlers (Last 5000) ==="
tail -5000 $ACCESS_LOG | grep -iE 'bot|crawl|spider' | awk '{print $1}' | sort | uniq -c | sort -rn | head -15

echo ""
echo "=== Sample of last 20 requests ==="
tail -20 $ACCESS_LOG | awk '{print $1, $4, $7, $9}'

echo "DONE"
