
import re
from datetime import datetime, timedelta

log_file = '/var/log/nginx/access.log'
now = datetime.now()
ten_mins_ago = now - timedelta(minutes=1440) # Check larger window first to see pattern

print(f"Checking Non-VN requests...\n")

try:
    with open(log_file, 'r') as f:
        for line in f:
            if 'cf_country="VN"' not in line:
                country_match = re.search(r'cf_country="([^"]+)"', line)
                if country_match:
                    country = country_match.group(1)
                    if country == "-": continue
                    
                    parts = re.findall(r'"([^"]*)"', line)
                    if len(parts) >= 3:
                        ua = parts[2]
                        status = line.split(' ')[8]
                        url_parts = parts[0].split(' ')
                        url = url_parts[1] if len(url_parts) > 1 else "Unknown"
                        print(f"[{country}] {status} | {url} | {ua}")
except Exception as e:
    print(f"Error: {e}")
