# ⚡ Setup Ghost CMS - Server 139.180.221.202 (Cloudflare SSL)

**Server:** 139.180.221.202  
**User:** root  
**Path:** /home/tradingview.com.vn  
**Domain:** tradingview.com.vn (Cloudflare SSL đã bật)  
**OS:** Ubuntu (Server trắng)

---

## 🎯 Setup hoàn chỉnh với Docker (15 phút)

### Bước 1: SSH vào server

```bash
ssh root@139.180.221.202
```

### Bước 2: Update hệ thống

```bash
apt-get update
apt-get upgrade -y
```

### Bước 3: Cài Docker & Docker Compose

```bash
# Cài Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Kiểm tra
docker --version
docker compose version
```

### Bước 4: Vào thư mục code

```bash
cd /home/tradingview.com.vn
```

### Bước 5: Cấu hình config.docker.json

```bash
nano config.docker.json
```

**Sửa các thông tin sau:**

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
      "password": "ĐỔI_PASSWORD_NÀY",
      "database": "ghostproduction"
    }
  },
  "mail": {
    "transport": "SMTP",
    "options": {
      "service": "SES",
      "host": "email-smtp.us-east-1.amazonaws.com",
      "port": 465,
      "secure": true,
      "auth": {
        "user": "AWS_SES_USER",
        "pass": "AWS_SES_PASSWORD"
      }
    }
  },
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "AWS_ACCESS_KEY",
      "secretAccessKey": "AWS_SECRET_KEY",
      "region": "us-east-1",
      "bucket": "TÊN_BUCKET",
      "assetHost": "https://cdn.tradingview.com.vn"
    }
  }
}
```

**Lưu:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Bước 6: Chạy script tự động setup Docker

```bash
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh
```

Script sẽ tự động:
- ✅ Kiểm tra Docker
- ✅ Build images
- ✅ Start containers (MySQL, Redis, Ghost)
- ✅ Hỏi có import database không

### Bước 7: Cài Nginx (chỉ làm reverse proxy)

```bash
apt-get install -y nginx
```

### Bước 8: Tạo Nginx config (KHÔNG CẦN SSL)

```bash
nano /etc/nginx/sites-available/tradingview.com.vn
```

**Nội dung config:**

```nginx
server {
    listen 80;
    server_name tradingview.com.vn www.tradingview.com.vn;

    # Cloudflare Real IP
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2a06:98c0::/29;
    set_real_ip_from 2c0f:f248::/32;
    real_ip_header CF-Connecting-IP;

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

    # Logging
    access_log /var/log/nginx/tradingview.access.log;
    error_log /var/log/nginx/tradingview.error.log;
}
```

**Lưu:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Bước 9: Kích hoạt Nginx config

```bash
# Kích hoạt site
ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/

# Xóa default site
rm /etc/nginx/sites-enabled/default

# Test config
nginx -t

# Reload Nginx
systemctl reload nginx
```

### Bước 10: Cấu hình Cloudflare

**Vào Cloudflare Dashboard:**

1. **DNS Settings:**
   - Type: `A`
   - Name: `@` (hoặc `tradingview.com.vn`)
   - Content: `139.180.221.202`
   - Proxy status: ✅ **Proxied** (màu cam)

   - Type: `A`
   - Name: `www`
   - Content: `139.180.221.202`
   - Proxy status: ✅ **Proxied** (màu cam)

2. **SSL/TLS Settings:**
   - SSL/TLS encryption mode: **Full** (không cần Full Strict vì server không có SSL)
   - Always Use HTTPS: ✅ **ON**
   - Automatic HTTPS Rewrites: ✅ **ON**

3. **Speed Settings (Optional):**
   - Auto Minify: ✅ CSS, JS, HTML
   - Brotli: ✅ ON

### Bước 11: Cấu hình Firewall (chỉ mở port cần thiết)

```bash
# Cài UFW
apt-get install -y ufw

# Mở port SSH
ufw allow 22/tcp

# Mở port HTTP (cho Cloudflare)
ufw allow 80/tcp

# KHÔNG cần mở port 443 vì SSL ở Cloudflare

# Kích hoạt firewall
ufw enable

# Kiểm tra
ufw status
```

### Bước 12: Kiểm tra hoạt động

```bash
# Kiểm tra containers
docker compose ps

# Kiểm tra logs
docker compose logs ghost --tail 50

# Test local
curl http://localhost:3005

# Test qua Nginx
curl http://localhost
```

### Bước 13: Truy cập website

- **Frontend:** https://tradingview.com.vn
- **Admin:** https://tradingview.com.vn/ghost

---

## ✅ Checklist hoàn chỉnh

- [ ] SSH vào server
- [ ] Update hệ thống: `apt-get update && apt-get upgrade -y`
- [ ] Cài Docker: `curl -fsSL https://get.docker.com | sh`
- [ ] Vào thư mục: `cd /home/tradingview.com.vn`
- [ ] Sửa `config.docker.json`
- [ ] Chạy: `bash scripts/docker-setup.sh`
- [ ] Cài Nginx: `apt-get install -y nginx`
- [ ] Tạo Nginx config (không SSL)
- [ ] Kích hoạt Nginx
- [ ] Cấu hình Cloudflare DNS (Proxied)
- [ ] Cấu hình Cloudflare SSL (Full mode)
- [ ] Setup Firewall: chỉ mở port 22, 80
- [ ] Truy cập: https://tradingview.com.vn

---

## 🔧 Quản lý

```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# Restart Ghost
docker compose restart ghost

# Xem logs
docker compose logs -f ghost

# Xem status
docker compose ps
```

---

## 🔄 Backup

```bash
# Backup database
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup_$(date +%Y%m%d).sql
gzip backup_*.sql

# Backup Ghost content
docker run --rm -v tradingviewcomvn_ghost_content:/data -v $(pwd):/backup alpine tar czf /backup/ghost_content_$(date +%Y%m%d).tar.gz -C /data .
```

---

## 🆘 Troubleshooting

### Ghost không start
```bash
docker compose logs ghost
docker compose restart ghost
```

### Cloudflare Error 521 (Web server is down)
```bash
# Kiểm tra Nginx
systemctl status nginx
nginx -t

# Kiểm tra Ghost
docker compose ps
curl http://localhost:3005
```

### Cloudflare Error 522 (Connection timed out)
```bash
# Kiểm tra firewall có mở port 80
ufw status

# Kiểm tra Nginx đang lắng nghe
netstat -tulpn | grep :80
```

---

**Chúc bạn setup thành công! 🎉**


