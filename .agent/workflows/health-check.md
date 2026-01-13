---
description: Kiểm tra tổng thể database, logs và server resources (Dành cho Server Ghost 57.129.45.30)
---

# Workflow: Health Check Toàn Diện (Optimized)

// turbo-all

---

## 🚀 Quick Check (Tất cả trong 1)

Lệnh tối ưu để xem nhanh trạng thái toàn bộ hệ thống. Chạy lệnh này để copy/paste nhanh:

```bash
ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'SELECT \"---DB--- \"; SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS MB FROM information_schema.TABLES WHERE table_schema = \"ghostproduction\" ORDER BY 2 DESC LIMIT 5;' 2>&1 | grep -v Warning; echo; echo '---CONTAINERS---'; cd /home/tradingview.com.vn && docker compose ps; echo; echo '---RESOURCES---'; free -h | grep Mem; df -h | grep '/$'; echo; echo '---ERRORS---'; docker compose logs --tail=50 --since 1h | grep -Ei 'error|fail|502|504' || echo 'Clean'; echo; echo '---WP---'; curl -s -o /dev/null -w 'Time: %{time_total}s\n' http://localhost:3005"
```

---

## 🔍 Chi Tiết Từng Phần

### Bước 1: Database Sâu

```bash
ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS MB, table_rows FROM information_schema.TABLES WHERE table_schema = \"ghostproduction\" ORDER BY 2 DESC LIMIT 10; SELECT COUNT(*) as actions_count FROM actions;'"
```

### Bước 2: Logs

```bash
ssh root@57.129.45.30 "cd /home/tradingview.com.vn && docker compose logs --tail=100 --since 1h | grep -Ei 'error|warn|503|500|fail' || echo 'Clean'"
```

### Bước 3: Tài nguyên

```bash
ssh root@57.129.45.30 "echo '---DISK---'; df -h | grep '/$'; echo '---RAM---'; free -h; echo '---CONN---'; ss -ant | grep ESTAB | wc -l"
```

---

## 🛠 Actions (CẦN CONFIRM)

- **Optimize**: `ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'OPTIMIZE TABLE posts; OPTIMIZE TABLE actions;'"`
- **Cleanup Log**: `ssh root@57.129.45.30 "docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e 'DELETE FROM actions WHERE created_at < DATE_SUB(NOW(), INTERVAL 60 DAY);'"`
- **Restart**: `ssh root@57.129.45.30 "cd /home/tradingview.com.vn && docker compose restart"`
- **Prune Docker**: `ssh root@57.129.45.30 "docker system prune -f"`
