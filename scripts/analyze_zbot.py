
import re
from collections import Counter

log_files = ['/var/log/nginx/access.log', '/var/log/nginx/access.log.1']
zbot_data = []

print(f"--- Analyzing '_zbot' activity ---")

for log_file in log_files:
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if '_zbot' in line:
                    # Extract info
                    country_match = re.search(r'cf_country="([^"]+)"', line)
                    country = country_match.group(1) if country_match else "Unknown"
                    
                    status = line.split(' ')[8]
                    ip = line.split(' ')[0]
                    
                    parts = re.findall(r'"([^"]*)"', line)
                    ua = parts[2] if len(parts) >= 3 else "Unknown"
                    url = parts[0].split(' ')[1] if len(parts[0].split(' ')) > 1 else "Unknown"
                    
                    zbot_data.append({
                        'ip': ip,
                        'status': status,
                        'country': country,
                        'ua': ua,
                        'url': url,
                        'file': log_file
                    })
    except Exception as e:
        print(f"Error reading {log_file}: {e}")

# Group by IP and Country
stats = Counter()
for item in zbot_data:
    stats[(item['ip'], item['country'], item['status'])] += 1

print(f"{'IP':<15} | {'Country':<8} | {'Status':<6} | {'Count':<6}")
print("-" * 45)
for (ip, country, status), count in stats.most_common():
    print(f"{ip:<15} | {country:<8} | {status:<6} | {count:<6}")

print("\nSample User-Agents for _zbot:")
unique_uas = set(item['ua'] for item in zbot_data)
for ua in list(unique_uas)[:5]:
    print(f"- {ua}")

print("\nChecking if any were blocked (403/429) in access.log.1:")
blocked = [d for d in zbot_data if d['file'] == '/var/log/nginx/access.log.1' and d['status'] in ('403', '429')]
if blocked:
    print(f"Found {len(blocked)} blocked requests in log history.")
    for b in blocked[:5]:
        print(f"[{b['country']}] {b['ip']} - {b['url']}")
else:
    print("No blocked '_zbot' requests found in the current log range.")
