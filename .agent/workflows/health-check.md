---
description: Kiểm tra tổng thể database, logs và server resources (Dành cho Server Ghost 57.129.45.30)
---

# Workflow: Health Check Toàn Diện (Optimized)

// turbo-all

---

## 🚀 Automated Health Check

Script tự động kiểm tra toàn bộ hệ thống Ghost CMS (Database, Containers, Resources, Logs, Performance).

### Bước 1: Upload script lên server

```bash
scp d:\Project\traddingview.com.vn\.agent\scripts\health-check-tradingview.sh root@57.129.45.30:/tmp/health-check.sh
```

### Bước 2: Chạy health check

```bash
ssh root@57.129.45.30 "chmod +x /tmp/health-check.sh && /tmp/health-check.sh"
```

---

## 🛠 Actions (CẦN CONFIRM)

- **Optimize**: `ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'OPTIMIZE TABLE posts; OPTIMIZE TABLE actions;'"`
- **Cleanup Log**: `ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'DELETE FROM actions WHERE created_at < DATE_SUB(NOW(), INTERVAL 60 DAY);'"`
- **Restart**: `ssh root@57.129.45.30 "cd /home/tradingview.com.vn && docker compose restart"`
- **Prune Docker**: `ssh root@57.129.45.30 "docker system prune -f"`
