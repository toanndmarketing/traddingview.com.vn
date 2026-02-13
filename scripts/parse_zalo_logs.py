
import re
from collections import Counter

zalo_uas = Counter()
log_path = '/var/log/nginx/access.log.1'

try:
    with open(log_path, 'r') as f:
        for line in f:
            if 'Zalo' in line:
                # detailed format: remote_addr - remote_user [time_local] "request" status body_bytes_sent "referer" "user_agent"
                # We want the content of the 3rd set of double quotes (User-Agent)
                parts = re.findall(r'"([^"]*)"', line)
                if len(parts) >= 3:
                    ua = parts[2]
                    status = line.split(' ')[8]
                    if 'Zalo' in ua:
                        zalo_uas[(ua, status)] += 1

    print(f"{'Count':<6} | {'Status':<6} | {'User-Agent'}")
    print("-" * 50)
    for (ua, status), count in zalo_uas.most_common(50):
        print(f"{count:<6} | {status:<6} | {ua}")
except Exception as e:
    print(f"Error: {e}")
