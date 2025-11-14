# 🐳 Hướng dẫn Setup Ghost CMS bằng Docker trên Server 139.180.221.202

**Server:** 139.180.221.202  
**User:** root  
**Code path:** /home/tradingview.com.vn  
**Phương pháp:** Docker Compose (Đơn giản & Dễ quản lý)

---

## ✨ Ưu điểm của Docker

- ✅ **Đơn giản**: Không cần cài Node.js, MySQL thủ công
- ✅ **Độc lập**: Mọi thứ chạy trong container, không ảnh hưởng hệ thống
- ✅ **Dễ quản lý**: Start/stop/restart chỉ với 1 lệnh
- ✅ **Dễ backup**: Backup volumes là xong
- ✅ **Dễ scale**: Có thể tăng resources dễ dàng

---

## 📋 Yêu cầu

- ✅ Docker
- ✅ Docker Compose
- ✅ Nginx (cho reverse proxy)

---

## 🚀 Các bước Setup

### Bước 1: SSH vào server

```bash
ssh root@139.180.221.202
```

### Bước 2: Cài đặt Docker & Docker Compose (nếu chưa có)

```bash
# Update system
apt-get update

# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Kiểm tra Docker
docker --version

# Cài đặt Docker Compose (nếu chưa có)
apt-get install -y docker-compose-plugin

# Hoặc cài bản standalone
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Kiểm tra
docker compose version
```

### Bước 3: Kiểm tra code

```bash
cd /home/tradingview.com.vn
ls -la
```

Nếu chưa có code:

```bash
cd /home
git clone <repository-url> tradingview.com.vn
cd tradingview.com.vn
```

### Bước 4: Tạo Dockerfile (nếu chưa có)

```bash
cd /home/tradingview.com.vn
nano Dockerfile
```

Nội dung Dockerfile:

```dockerfile
FROM ghost:5.58.0-alpine

# Install dependencies
WORKDIR /var/lib/ghost

# Copy package.json for S3 adapter
COPY package.json ./
RUN npm install --production

# Copy S3 adapter to content/adapters
RUN mkdir -p content/adapters/storage && \
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3

# Copy custom themes
COPY content/themes ./content/themes

# Set permissions
RUN chown -R node:node /var/lib/ghost/content

# Expose port
EXPOSE 3000

# Start Ghost
CMD ["node", "current/index.js"]
```

**Lưu:** `Ctrl+O` → `Enter` → `Ctrl+X`

### Bước 5: Cấu hình config.docker.json

```bash
nano config.docker.json
```

Chỉnh sửa các thông tin:

```json
{
  "url": "https://tradingview.com.vn",
  "server": {
    "port": 3000,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "mysql",
      "user": "ghost-814",
      "password": "6xJhHy7gsq61hTC3KdVq",
      "port": 3306,
      "database": "ghostproduction"
    }
  },
  "mail": {
    "transport": "SMTP",
    "options": {
      "host": "email-smtp.ap-southeast-1.amazonaws.com",
      "port": 465,
      "service": "SES",
      "secure": true,
      "auth": {
        "user": "YOUR_AWS_SES_USER",
        "pass": "YOUR_AWS_SES_PASSWORD"
      }
    },
    "from": "'TradingView Vietnam' <noreply@tradingview.com.vn>"
  },
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "YOUR_AWS_ACCESS_KEY_ID",
      "secretAccessKey": "YOUR_AWS_SECRET_ACCESS_KEY",
      "region": "ap-southeast-1",
      "bucket": "tradingview-prd",
      "assetHost": "https://your-cdn-url.com",
      "forcePathStyle": true,
      "signatureVersion": "v4",
      "acl": "private"
    }
  }
}
```

**Lưu:** `Ctrl+O` → `Enter` → `Ctrl+X`

### Bước 6: Kiểm tra docker-compose.yml

```bash
cat docker-compose.yml
```

File này đã có sẵn trong source. Nếu cần chỉnh sửa:

```bash
nano docker-compose.yml
```

**Lưu ý:** Đổi port nếu cần (mặc định Ghost chạy ở port 3005)

### Bước 7: Build và khởi động containers

```bash
cd /home/tradingview.com.vn

# Build images
docker compose build

# Khởi động containers
docker compose up -d

# Xem logs
docker compose logs -f
```

**Giải thích:**
- `docker compose build`: Build Ghost image với S3 adapter
- `docker compose up -d`: Khởi động tất cả containers (MySQL, Redis, Ghost) ở chế độ background
- `docker compose logs -f`: Xem logs realtime

### Bước 8: Import Database (nếu có backup)

```bash
cd /home/tradingview.com.vn

# Nếu file .sql.gz, giải nén trước
gunzip database_new.sql.gz

# Import vào MySQL container
docker compose exec -T mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction < database_new.sql

# Hoặc dùng root user
docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < database_new.sql
```

### Bước 9: Kiểm tra containers đang chạy

```bash
# Xem status
docker compose ps

# Xem logs của Ghost
docker compose logs ghost

# Xem logs của MySQL
docker compose logs mysql

# Xem logs realtime
docker compose logs -f ghost
```

### Bước 10: Cài đặt Nginx Reverse Proxy

```bash
# Cài đặt Nginx (nếu chưa có)
apt-get install -y nginx

# Tạo file config
nano /etc/nginx/sites-available/tradingview.com.vn
```

Nội dung Nginx config:

```nginx
server {
    listen 80;
    server_name tradingview.com.vn www.tradingview.com.vn;

    # Redirect to HTTPS (sau khi có SSL)
    # return 301 https://$server_name$request_uri;

    location / {
        proxy_pass http://127.0.0.1:3005;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Client max body size
    client_max_body_size 50M;
}
```

**Kích hoạt site:**

```bash
# Tạo symbolic link
ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/

# Xóa default site (nếu cần)
rm /etc/nginx/sites-enabled/default

# Test config
nginx -t

# Reload Nginx
systemctl reload nginx
```

### Bước 11: Cài đặt SSL với Let's Encrypt

```bash
# Cài đặt Certbot
apt-get install -y certbot python3-certbot-nginx

# Lấy SSL certificate
certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn

# Certbot sẽ tự động cấu hình HTTPS
```

### Bước 12: Setup auto-start khi reboot

Docker Compose đã có `restart: unless-stopped` nên containers sẽ tự động khởi động khi server reboot.

Kiểm tra:

```bash
# Reboot server
reboot

# Sau khi reboot, SSH lại và kiểm tra
docker compose ps
```

---

## ✅ Kiểm tra hoạt động

### 1. Kiểm tra containers

```bash
cd /home/tradingview.com.vn

# Xem tất cả containers
docker compose ps

# Kết quả mong đợi:
# NAME                STATUS              PORTS
# ghost-mysql         Up                  0.0.0.0:3306->3306/tcp
# ghost-redis         Up                  6379/tcp
# ghost-tradingview   Up                  0.0.0.0:3005->3000/tcp
```

### 2. Kiểm tra logs

```bash
# Logs của Ghost
docker compose logs ghost --tail 50

# Logs của MySQL
docker compose logs mysql --tail 50

# Logs realtime
docker compose logs -f
```

### 3. Test local

```bash
# Test Ghost port
curl http://127.0.0.1:3005

# Test MySQL
docker compose exec mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq -e "SHOW DATABASES;"
```

### 4. Truy cập website

- Frontend: `https://tradingview.com.vn`
- Admin: `https://tradingview.com.vn/ghost`

---

## 🛠️ Các lệnh quản lý Docker

```bash
cd /home/tradingview.com.vn

# Start tất cả containers
docker compose up -d

# Stop tất cả containers
docker compose down

# Restart tất cả containers
docker compose restart

# Restart chỉ Ghost
docker compose restart ghost

# Xem logs
docker compose logs -f ghost

# Xem status
docker compose ps

# Rebuild và restart
docker compose up -d --build

# Vào shell của Ghost container
docker compose exec ghost sh

# Vào MySQL shell
docker compose exec mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction
```

---

## 🔄 Backup & Restore

### Backup Database

```bash
cd /home/tradingview.com.vn

# Backup database
docker compose exec mysql mysqldump -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction > backup_$(date +%Y%m%d_%H%M%S).sql

# Hoặc dùng root
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup_$(date +%Y%m%d_%H%M%S).sql

# Nén backup
gzip backup_*.sql
```

### Backup Volumes

```bash
# Backup Ghost content
docker run --rm -v tradingviewcomvn_ghost_content:/data -v $(pwd):/backup alpine tar czf /backup/ghost_content_backup.tar.gz -C /data .

# Backup MySQL data
docker run --rm -v tradingviewcomvn_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_data_backup.tar.gz -C /data .
```

### Restore Database

```bash
cd /home/tradingview.com.vn

# Giải nén backup (nếu cần)
gunzip backup_20241113.sql.gz

# Restore
docker compose exec -T mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq ghostproduction < backup_20241113.sql

# Restart Ghost
docker compose restart ghost
```

---

## 🔄 Update Code

```bash
cd /home/tradingview.com.vn

# Backup database trước
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup_before_update_$(date +%Y%m%d).sql

# Pull code mới
git pull origin main

# Rebuild và restart
docker compose up -d --build

# Xem logs
docker compose logs -f ghost
```

---

## 🐛 Troubleshooting

### Ghost không start được

```bash
# Xem logs chi tiết
docker compose logs ghost --tail 100

# Restart Ghost
docker compose restart ghost

# Rebuild Ghost image
docker compose up -d --build ghost
```

### Lỗi MySQL connection

```bash
# Kiểm tra MySQL đang chạy
docker compose ps mysql

# Xem logs MySQL
docker compose logs mysql

# Restart MySQL
docker compose restart mysql

# Test connection
docker compose exec mysql mysql -u ghost-814 -p6xJhHy7gsq61hTC3KdVq -e "SHOW DATABASES;"
```

### Lỗi port đã được sử dụng

```bash
# Kiểm tra port 3005
netstat -tulpn | grep 3005
# hoặc
ss -tulpn | grep 3005

# Nếu port bị chiếm, đổi port trong docker-compose.yml
nano docker-compose.yml
# Sửa: ports: - "3006:3000"

# Restart
docker compose down
docker compose up -d
```

### Lỗi permissions

```bash
# Fix permissions cho volumes
docker compose down
docker volume rm tradingviewcomvn_ghost_content
docker compose up -d
```

### Container bị crash liên tục

```bash
# Xem logs
docker compose logs ghost --tail 200

# Kiểm tra resources
docker stats

# Tăng memory limit trong docker-compose.yml nếu cần
```

---

## 📊 Monitoring

### Xem resource usage

```bash
# Xem tất cả containers
docker stats

# Xem chỉ Ghost
docker stats ghost-tradingview

# Xem disk usage
docker system df

# Xem volumes
docker volume ls
```

### Cleanup

```bash
# Xóa unused images
docker image prune -a

# Xóa unused volumes
docker volume prune

# Xóa unused networks
docker network prune

# Xóa tất cả unused resources
docker system prune -a
```

---

## 🔐 Bảo mật

### 1. Đổi password MySQL

```bash
# Sửa trong docker-compose.yml
nano docker-compose.yml

# Sửa:
# MYSQL_PASSWORD: new_strong_password

# Sửa trong config.docker.json
nano config.docker.json

# Rebuild và restart
docker compose down
docker compose up -d
```

### 2. Không expose MySQL port ra ngoài

```bash
# Sửa docker-compose.yml
nano docker-compose.yml

# Xóa hoặc comment dòng:
# ports:
#   - "3306:3306"

# Restart
docker compose down
docker compose up -d
```

### 3. Firewall

```bash
# Chỉ mở port cần thiết
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Không mở port 3005 (chỉ dùng qua Nginx)
# Không mở port 3306 (MySQL chỉ dùng internal)

ufw enable
ufw status
```

---

## 📝 So sánh Docker vs Non-Docker

| Tiêu chí | Docker | Non-Docker |
|----------|--------|------------|
| **Cài đặt** | ✅ Đơn giản (1 lệnh) | ⚠️ Phức tạp (nhiều bước) |
| **Dependencies** | ✅ Tự động | ⚠️ Phải cài thủ công |
| **Isolation** | ✅ Độc lập hoàn toàn | ❌ Ảnh hưởng hệ thống |
| **Backup** | ✅ Backup volumes | ⚠️ Backup nhiều nơi |
| **Update** | ✅ Rebuild image | ⚠️ Update từng phần |
| **Rollback** | ✅ Dễ dàng | ⚠️ Khó khăn |
| **Resources** | ⚠️ Hơi tốn RAM | ✅ Tối ưu hơn |

**Khuyến nghị:** Dùng Docker cho môi trường production vì dễ quản lý và bảo trì.

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. **Logs:** `docker compose logs -f ghost`
2. **Status:** `docker compose ps`
3. **Restart:** `docker compose restart`
4. **Rebuild:** `docker compose up -d --build`

---

## 📋 Checklist hoàn chỉnh

- [ ] SSH vào server 139.180.221.202
- [ ] Cài đặt Docker & Docker Compose
- [ ] Kiểm tra code tại /home/tradingview.com.vn
- [ ] Tạo Dockerfile
- [ ] Cấu hình config.docker.json
- [ ] Build images: `docker compose build`
- [ ] Start containers: `docker compose up -d`
- [ ] Import database (nếu có)
- [ ] Kiểm tra containers: `docker compose ps`
- [ ] Cài đặt Nginx reverse proxy
- [ ] Cài đặt SSL
- [ ] Test website
- [ ] Setup backup tự động

---

**Chúc bạn setup thành công! 🎉**

**Lưu ý:** Với Docker, bạn không cần cài Node.js, MySQL, PM2 thủ công. Mọi thứ đã được đóng gói trong containers!


