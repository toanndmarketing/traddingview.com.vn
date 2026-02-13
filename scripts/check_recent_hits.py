
import re
from datetime import datetime

log_file = '/var/log/nginx/access.log'
target_url = 'du-bao-gia-vang-xau-usd-duy-tri-xu-huong-tang-gia-gan-muc-cao-ky-luc-truoc-quyet-dinh-cua-fed'

print(f"--- Recent hits for target URL (Last 15 minutes) ---")

try:
    with open(log_file, 'r') as f:
        lines = f.readlines()
        
    for line in lines[-2000:]: # Look at last 2000 lines
        if target_url in line:
            # Extract timestamp: [27/Jan/2026:14:31:09 +0000]
            ts_match = re.search(r'\[(.*?)\]', line)
            if ts_match:
                ts_str = ts_match.group(1).split(' ')[0]
                # Filter for very recent if needed, but for now just show them
                
            country_match = re.search(r'cf_country="([^"]+)"', line)
            country = country_match.group(1) if country_match else "Unknown"
            
            parts = re.findall(r'"([^"]*)"', line)
            if len(parts) >= 3:
                ua = parts[2]
                status = line.split(' ')[8]
                ip = line.split(' ')[0]
                print(f"[{ts_str}] [{country}] {status} | {ip} | {ua}")

except Exception as e:
    print(f"Error: {e}")
