# 🚀 Hướng dẫn tối ưu Ghost CMS - Query Performance

## 📋 Vấn đề phát hiện

Ghost CMS đang thực hiện query với **hàng trăm post IDs**, gây ra lỗi:
```
Got a packet bigger than 'max_allowed_packet' bytes
```

Query mẫu:
```sql
SELECT * FROM posts 
WHERE id IN ('693b5b09...', '693b7d38...', ... [300+ IDs]) 
ORDER BY sort_order ASC
```

---

## 💡 Các giải pháp tối ưu

### 1️⃣ **Tối ưu Database Indexes** (Khuyến nghị cao)

#### Kiểm tra indexes hiện tại:
```bash
ssh root@139.180.221.202
docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e "SHOW INDEX FROM posts;"
```

#### Tạo indexes cần thiết:
```sql
-- Index cho primary_tag (thường dùng trong related posts)
CREATE INDEX idx_posts_primary_tag ON posts(primary_tag);

-- Index cho published_at (sắp xếp)
CREATE INDEX idx_posts_published_at ON posts(published_at DESC);

-- Index cho status + published_at (filter + sort)
CREATE INDEX idx_posts_status_published ON posts(status, published_at DESC);

-- Index cho visibility
CREATE INDEX idx_posts_visibility ON posts(visibility);
```

#### Script tự động:
```bash
cd /home/traddingview.com.vn
cat > scripts/optimize-mysql-indexes.sql << 'EOF'
USE ghostproduction;

-- Kiểm tra indexes hiện tại
SHOW INDEX FROM posts;

-- Tạo indexes nếu chưa có
CREATE INDEX IF NOT EXISTS idx_posts_primary_tag ON posts(primary_tag);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON posts(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_status_published ON posts(status, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_visibility ON posts(visibility);

-- Optimize tables
OPTIMIZE TABLE posts;
OPTIMIZE TABLE posts_tags;
OPTIMIZE TABLE tags;

-- Analyze tables
ANALYZE TABLE posts;
ANALYZE TABLE posts_tags;
ANALYZE TABLE tags;

SHOW INDEX FROM posts;
EOF

# Chạy script
docker exec -i ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction < scripts/optimize-mysql-indexes.sql
```

---

### 2️⃣ **Tối ưu MySQL Configuration**

Đã fix: ✅ `max_allowed_packet=1GB`

Các config khác cần kiểm tra:

```yaml
# docker-compose.yml - MySQL service
command:
  - --max-allowed-packet=1073741824        # ✅ Đã fix
  - --innodb-buffer-pool-size=2G           # Tăng từ 1G lên 2G
  - --query-cache-size=0                   # Disable query cache (deprecated)
  - --tmp-table-size=256M                  # Tăng temp table size
  - --max-heap-table-size=256M             # Tăng heap table size
  - --join-buffer-size=8M                  # Tăng join buffer
  - --sort-buffer-size=8M                  # Tăng sort buffer
```

---

### 3️⃣ **Enable MySQL Slow Query Log** (Để phát hiện queries chậm)

```bash
# Tạo file config
cat > /home/traddingview.com.vn/mysql-slow-query.cnf << 'EOF'
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
log_queries_not_using_indexes = 1
EOF

# Update docker-compose.yml
# Thêm volume mount:
volumes:
  - ./mysql-slow-query.cnf:/etc/mysql/conf.d/slow-query.cnf:ro
  - mysql_logs:/var/log/mysql

# Restart MySQL
docker compose restart mysql

# Xem slow queries
docker exec ghost-mysql tail -f /var/log/mysql/slow-query.log
```

---

### 4️⃣ **Giới hạn số lượng posts trong theme**

Kiểm tra và giảm `limit` trong các file `.hbs`:

```bash
# Tìm tất cả queries không có limit hoặc limit quá lớn
cd /home/traddingview.com.vn/content/themes/tradingview-v6
grep -rn "{{#get" . --include="*.hbs" | grep -E "limit=\"[0-9]{2,}\""
```

**Khuyến nghị:**
- Related posts: `limit="4"` ✅
- Tag pages: `limit="15"` (pagination)
- Homepage: `limit="10"`
- Sidebar: `limit="5"`

---

### 5️⃣ **Tối ưu Ghost Cache với Redis**

Đã có Redis, nhưng cần verify config:

```bash
# Kiểm tra Redis connection
docker exec ghost-tradingview sh -c "node -e \"
const redis = require('redis');
const client = redis.createClient({host: 'redis', port: 6379});
client.on('connect', () => console.log('Redis connected!'));
client.on('error', (err) => console.log('Redis error:', err));
\""
```

Trong `config.docker.json`, verify:
```json
{
  "adapters": {
    "cache": {
      "Redis": {
        "host": "redis",
        "port": 6379,
        "ttl": 600  // Cache 10 phút
      }
    }
  }
}
```

**Tăng TTL cho performance tốt hơn:**
```json
"ttl": 3600  // Cache 1 giờ
```

---

### 6️⃣ **Pagination cho Tag Pages**

Nếu có tag có quá nhiều bài (>100), cần enable pagination:

```handlebars
{{!-- tag.hbs --}}
{{#get "posts" filter="tags:{{tag.slug}}" limit="15" as |tag_posts|}}
  {{#foreach tag_posts}}
    {{!-- Post card --}}
  {{/foreach}}
  
  {{!-- Pagination --}}
  {{pagination}}
{{/get}}
```

---

### 7️⃣ **Monitoring & Alerts**

#### Script kiểm tra query performance:

```bash
#!/bin/bash
# scripts/check-mysql-performance.sh

echo "=== Top 10 Slow Queries ==="
docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e "
SELECT 
  SUBSTRING(query, 1, 100) as query_preview,
  COUNT(*) as count,
  AVG(query_time) as avg_time
FROM mysql.slow_log
GROUP BY query_preview
ORDER BY avg_time DESC
LIMIT 10;
"

echo ""
echo "=== Current Connections ==="
docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e "SHOW PROCESSLIST;"

echo ""
echo "=== Table Sizes ==="
docker exec ghost-mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction -e "
SELECT 
  table_name,
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
  table_rows
FROM information_schema.TABLES
WHERE table_schema = 'ghostproduction'
ORDER BY (data_length + index_length) DESC;
"
```

---

## 🎯 Action Plan (Thực hiện ngay)

### Bước 1: Tạo indexes (5 phút)
```bash
ssh root@139.180.221.202
cd /home/traddingview.com.vn
# Copy script optimize-mysql-indexes.sql từ trên
# Chạy script
```

### Bước 2: Enable slow query log (2 phút)
```bash
# Copy config từ section 3
# Restart MySQL
```

### Bước 3: Monitor trong 24h
```bash
# Xem slow queries
docker exec ghost-mysql tail -f /var/log/mysql/slow-query.log

# Kiểm tra performance
bash scripts/check-mysql-performance.sh
```

### Bước 4: Tối ưu theme nếu cần
```bash
# Sau khi có slow query log, xác định query nào chậm
# Điều chỉnh limit trong theme
```

---

## 📊 Expected Results

Sau khi tối ưu:
- ✅ Query time giảm 50-70%
- ✅ Không còn lỗi max_allowed_packet
- ✅ Page load time giảm
- ✅ MySQL CPU usage giảm

---

## 🔧 Troubleshooting

### Nếu vẫn có query lớn:

1. **Kiểm tra số lượng posts theo tag:**
```sql
SELECT t.name, COUNT(pt.post_id) as post_count
FROM tags t
LEFT JOIN posts_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY post_count DESC
LIMIT 20;
```

2. **Tìm tag có quá nhiều bài:**
- Nếu tag có >200 bài → Cần split hoặc archive
- Nếu tag có >500 bài → Cần refactor content strategy

3. **Kiểm tra Ghost version:**
```bash
docker exec ghost-tradingview node -e "console.log(require('./current/package.json').version)"
```

Nếu < 5.80, cân nhắc upgrade (có nhiều performance improvements).

---

## 📞 Support

Nếu cần hỗ trợ thêm:
1. Export slow query log
2. Kiểm tra MySQL processlist khi có vấn đề
3. Review theme code
