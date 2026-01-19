#!/bin/bash
# Traffic Analysis Script for TradingView Ghost CMS
# Server: 57.129.45.30

echo "=========================================="
echo "TRAFFIC ANALYSIS - $(date)"
echo "=========================================="

ACCESS_LOG="/var/log/nginx/access.log"

echo ""
echo "=== TOP 30 IPs (hôm nay) ==="
cat $ACCESS_LOG | awk '{print $1}' | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== Geographic Distribution (Countries) ==="
grep -oP 'cf_country="\K[^"]+' $ACCESS_LOG | sort | uniq -c | sort -rn | head -15

echo ""
echo "=== Request Types ==="
cat $ACCESS_LOG | awk '{print $6}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== HTTP Status Codes ==="
cat $ACCESS_LOG | awk '{print $9}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== TOP URLs được request nhiều nhất ==="
cat $ACCESS_LOG | awk '{print $7}' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== Suspicious User Agents (bots, crawlers) ==="
grep -iE 'bot|crawl|spider|python|curl|wget|scrapy|headless' $ACCESS_LOG | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== IPs có nhiều request trong thời gian ngắn (potential spam) ==="
# Lấy last 1000 requests và đếm thời gian
cat $ACCESS_LOG | tail -5000 | awk '{print $1, $4}' | cut -d: -f1-3 | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== Request per minute (last 100 entries) ==="
cat $ACCESS_LOG | tail -100 | awk '{print $4}' | cut -d: -f1-3 | uniq -c

echo ""
echo "=== Response Times (slow requests > 1s) ==="
grep -oP 'rt=\K[0-9.]+' $ACCESS_LOG | awk '$1 > 1 {count++} END {print "Slow requests (>1s): " count}'

echo ""
echo "=========================================="
echo "ANALYSIS COMPLETE"
echo "=========================================="
