
import re

log_file = '/var/log/nginx/access.log'
target_url = 'du-bao-gia-vang-xau-usd-duy-tri-xu-huong-tang-gia-gan-muc-cao-ky-luc-truoc-quyet-dinh-cua-fed'

print(f"Checking updates for: {target_url}\n")

try:
    with open(log_file, 'r') as f:
        for line in f:
            if target_url in line:
                # Check for SG or other non-VN countries
                country_match = re.search(r'cf_country="([^"]+)"', line)
                country = country_match.group(1) if country_match else "Unknown"
                
                parts = re.findall(r'"([^"]*)"', line)
                if len(parts) >= 3:
                     ua = parts[2]
                     status = line.split(' ')[8]
                     print(f"[{country}] {status} | {ua}")
except Exception as e:
    print(f"Error: {e}")
