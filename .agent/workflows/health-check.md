---
description: Kiểm tra tổng thể database, logs và server resources
---

# Workflow: Health Check Toàn Diện

Workflow này kiểm tra:
1. Database optimization status
2. Docker container logs
3. Server resources (CPU, RAM, Disk)

---

## Bước 1: Kiểm tra Database Optimization & Size

// turbo
```bash
ssh root@139.180.221.202 "docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e \"
SELECT '=== TOP 10 TABLES BY SIZE ===' as info;
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    table_rows as 'Rows',
    ROUND((index_length / 1024 / 1024), 2) AS 'Index Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'ghostproduction'
ORDER BY (data_length + index_length) DESC
LIMIT 10;

SELECT '=== FRAGMENTATION CHECK ===' as info;
SELECT 
    table_name,
    ROUND(data_length / 1024 / 1024, 2) as 'Data (MB)',
    ROUND(data_free / 1024 / 1024, 2) as 'Free (MB)',
    ROUND((data_free / data_length) * 100, 2) as 'Fragmentation %'
FROM information_schema.TABLES
WHERE table_schema = 'ghostproduction' 
    AND data_free > 0
ORDER BY data_free DESC;

SELECT '=== ACTIONS LOG STATUS ===' as info;
SELECT COUNT(*) as total_rows, MIN(created_at) as oldest_record FROM actions;
\" 2>&1 | grep -v Warning"
```

**Đánh giá:**
- ✅ Fragmentation < 10% → OK
- ⚠️ fragmentation 10-20% hoặc actions > 500k rows → Cân nhắc optimize/cleanup
- ❌ Fragmentation > 20% → Cần optimize ngay

---

## Bước 2: Kiểm tra Docker Container Logs

### 2.1 Ghost Container Logs

// turbo
```bash
ssh root@139.180.221.202 "cd /home/traddingview.com.vn ; echo '=== GHOST LOGS (Last 50 lines) ===' ; docker compose logs ghost --tail=50 --since 1h | grep -E 'ERROR|error|Error|WARN|warn|503|500|fail|crash|killed' || echo 'No errors found in last hour'"
```

### 2.2 MySQL Container Logs

// turbo
```bash
ssh root@139.180.221.202 "cd /home/traddingview.com.vn ; echo '=== MYSQL LOGS (Last 50 lines) ===' ; docker compose logs mysql --tail=50 --since 1h | grep -E 'ERROR|error|Error|WARN|warn|crash|killed|denied' || echo 'No errors found in last hour'"
```

### 2.3 Nginx Container Logs

// turbo
```bash
ssh root@139.180.221.202 "cd /home/traddingview.com.vn ; echo '=== NGINX ERROR LOGS ===' ; docker compose logs nginx --tail=50 --since 1h | grep -E 'error|warn|fail|502|503|504' || echo 'No errors found in last hour'"
```

### 2.4 All Containers Status

// turbo
```bash
ssh root@139.180.221.202 "cd /home/traddingview.com.vn ; echo '=== CONTAINER STATUS ===' ; docker compose ps ; echo '' ; echo '=== CONTAINER HEALTH ===' ; docker inspect ghost-tradingview --format='Ghost Health: {{.State.Health.Status}}' ; docker inspect ghost-mysql --format='MySQL Health: {{.State.Health.Status}}'"
```

**Đánh giá:**
- ✅ Không có ERROR/WARN → OK
- ⚠️ Có WARN nhưng không ảnh hưởng → Monitor
- ❌ Có ERROR hoặc 5xx errors → Cần fix ngay

---

## Bước 3: Kiểm tra Server Resources

### 3.1 CPU & Memory Usage

// turbo
```bash
ssh root@139.180.221.202 "echo '=== CPU & MEMORY USAGE ===' ; top -bn1 | head -20 ; echo '' ; echo '=== MEMORY DETAILS ===' ; free -h ; echo '' ; echo '=== LOAD AVERAGE ===' ; uptime"
```

### 3.2 Disk Usage

// turbo
```bash
ssh root@139.180.221.202 "echo '=== DISK USAGE ===' ; df -h | grep -E 'Filesystem|/$|/home' ; echo '' ; echo '=== DOCKER DISK USAGE ===' ; docker system df"
```

### 3.3 Docker Container Resources

// turbo
```bash
ssh root@139.180.221.202 "echo '=== DOCKER CONTAINER STATS (5s snapshot) ===' ; docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}'"
```

### 3.4 Network Connections

// turbo
```bash
ssh root@139.180.221.202 "echo '=== ACTIVE CONNECTIONS ===' ; netstat -an | grep ESTABLISHED | wc -l ; echo 'connections' ; echo '' ; echo '=== LISTENING PORTS ===' ; netstat -tlnp | grep -E '3005|3306|6379|9000'"
```

**Đánh giá:**
- ✅ CPU < 70%, RAM < 80%, Disk < 80% → OK
- ⚠️ CPU 70-90%, RAM 80-90%, Disk 80-90% → Cần monitor
- ❌ CPU > 90%, RAM > 90%, Disk > 90% → Overload, cần scale

---

## Bước 4: Kiểm tra MySQL Performance

// turbo
```bash
ssh root@139.180.221.202 "docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e \"
SELECT '=== BUFFER POOL SIZE ===' as info;
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SELECT '=== CONNECTION STATUS ===' as info;
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';
SELECT '=== BUFFER POOL STATUS ===' as info;
SHOW STATUS LIKE 'Innodb_buffer_pool_pages_data';
SHOW STATUS LIKE 'Innodb_buffer_pool_pages_free';
\" 2>&1 | grep -v Warning"
```

**Đánh giá:**
- ✅ Threads_connected < 50, Buffer pool free > 0 → OK
- ⚠️ Buffer pool free gần hết → Cân nhắc tăng RAM cho MySQL
- ❌ Threads_connected > 100 → Cần tăng max_connections

---

## Bước 5: Kiểm tra Website Performance

// turbo
```bash
ssh root@139.180.221.202 "echo '=== WEBSITE RESPONSE TIME ===' ; for i in {1..3}; do time curl -s -o /dev/null http://localhost:3005 ; done"
```

**Đánh giá:**
- ✅ Response time < 0.5s → Excellent
- ⚠️ Response time 0.5-2s → OK
- ❌ Response time > 2s → Slow, cần optimize

---

## Bước 6: Tổng hợp kết quả

Sau khi chạy tất cả các bước trên, đánh giá theo tiêu chuẩn trong workflow.

---

## Actions nếu phát hiện vấn đề (CẦN CONFIRM)

### Database fragmentation cao:
```bash
ssh root@139.180.221.202 "docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e 'OPTIMIZE TABLE posts; OPTIMIZE TABLE posts_tags; OPTIMIZE TABLE tags;'"
```

### Dọn dẹp Log (Bảng actions) nếu quá nặng:
```bash
ssh root@139.180.221.202 "docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e 'DELETE FROM actions WHERE created_at < DATE_SUB(NOW(), INTERVAL 60 DAY); OPTIMIZE TABLE actions;'"
```

### Server overload / Slow:
```bash
# Restart containers để free memory và reload config
ssh root@139.180.221.202 "cd /home/traddingview.com.vn ; docker compose restart ghost mysql nginx"
```

### Disk space cao:
```bash
# Clean Docker images/volumes không dùng
ssh root@139.180.221.202 "docker system prune -f"
```

---

## Lưu ý

- Chạy workflow này **hàng ngày** để monitor
- **LUÔN CONFIRM** với user trước khi chạy các lệnh trong phần Actions.
- Backup database trước khi thực hiện optimization lớn.
