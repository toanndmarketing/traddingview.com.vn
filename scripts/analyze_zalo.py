
import re
from collections import Counter

country_counter = Counter()
ua_counter = Counter()

log_files = ['/var/log/nginx/access.log', '/var/log/nginx/access.log.1']

for log_file in log_files:
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if 'Zalo' in line:
                    # Extract Country
                    country_match = re.search(r'cf_country="(\w+)"', line)
                    if country_match:
                        country = country_match.group(1)
                        country_counter[country] += 1
                        
                        # If not VN, collect UA
                        if country != 'VN':
                             # Extract User-Agent (3rd quoted string)
                            parts = re.findall(r'"([^"]*)"', line)
                            if len(parts) >= 3:
                                ua = parts[2]
                                ua_counter[ua] += 1

    except FileNotFoundError:
        continue
    except Exception as e:
        print(f"Error reading {log_file}: {e}")

print("Zalo Requests by Country:")
for country, count in country_counter.most_common():
    print(f"{country}: {count}")

print("\nNon-VN Zalo User-Agents:")
for ua, count in ua_counter.most_common(10):
    print(f"{count}: {ua}")
