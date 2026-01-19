#!/bin/bash
# Deep Traffic Analysis - Real visitor IPs via Cloudflare headers
ACCESS_LOG="/var/log/nginx/access.log"

echo "=== TOP 30 Real IPs (via cf_ip header) ==="
tail -10000 $ACCESS_LOG | grep -oP 'cf_ip="\K[^"]+' | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== Countries (via cf_country) ==="
tail -10000 $ACCESS_LOG | grep -oP 'cf_country="\K[^"]+' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== User Agents Analysis ==="
tail -5000 $ACCESS_LOG | grep -oP '(?<=" ")[^"]+(?=" rt=)' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== Suspicious: Short session IPs (multiple single-page visits) ==="
# IPs that hit only 1-2 pages (potential bounce spam)
tail -10000 $ACCESS_LOG | grep -oP 'cf_ip="\K[^"]+' | sort | uniq -c | sort -rn | awk '$1 == 1 || $1 == 2 {print}' | head -30

echo ""
echo "=== Bot traffic by real IP ==="
tail -10000 $ACCESS_LOG | grep -iE 'bot|crawl|spider' | grep -oP 'cf_ip="\K[^"]+' | sort | uniq -c | sort -rn | head -20

echo ""
echo "=== Requests per minute pattern (last 2 hours) ==="
tail -20000 $ACCESS_LOG | awk '{print $4}' | cut -d: -f1-3 | uniq -c | tail -30

echo "DONE"
