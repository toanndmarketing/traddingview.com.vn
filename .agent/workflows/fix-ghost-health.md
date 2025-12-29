---
description: Fix Ghost container unhealthy và các lỗi liên quan
---

# Fix Ghost Container Unhealthy

## Vấn đề phát hiện

- Container ghost-tradingview: **unhealthy** (FailingStreak: 37,462)
- Health check fail: Connection refused
- Nginx cache errors: unlink() failed
- Slow query warnings

## Các bước khắc phục

### 1. Kiểm tra logs chi tiết

```bash
ssh root@57.129.45.30
cd /home/tradingview.com.vn
docker compose logs ghost --tail=1000 | less
```

### 2. Restart Ghost container

```bash
docker compose restart ghost
```

### 3. Nếu vẫn lỗi, rebuild Ghost container

```bash
# Backup trước
docker compose exec mysql mysqldump -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction > backup_$(date +%Y%m%d_%H%M%S).sql

# Rebuild
docker compose up -d --build --force-recreate ghost
```

### 4. Clear Nginx cache

```bash
docker compose exec nginx sh -c "rm -rf /var/cache/nginx/*"
docker compose restart nginx
```

### 5. Fix health check (nếu cần)

Sửa `docker-compose.yml`, thay health check từ wget sang nc:

```yaml
healthcheck:
  test: ["CMD", "nc", "-z", "localhost", "3000"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 6. Kiểm tra MySQL connection pool

```bash
docker compose exec mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq -e "SHOW PROCESSLIST;"
```

### 7. Monitor sau khi fix

```bash
# Xem logs realtime
docker compose logs -f ghost

# Kiểm tra health status
docker inspect ghost-tradingview --format='{{.State.Health.Status}}'
```

## Rollback nếu cần

```bash
# Stop containers
docker compose stop

# Restore database
docker compose exec -T mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction < backup_YYYYMMDD_HHMMSS.sql

# Start lại
docker compose up -d
```
