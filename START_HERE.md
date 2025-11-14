# 🚀 SETUP GHOST CMS - 10 PHÚT

**Server:** 139.180.221.202 | **Domain:** tradingview.com.vn (Cloudflare SSL)

---

## ⚡ COPY & PASTE - 10 LỆNH

```bash
# 1. SSH vào server
ssh root@139.180.221.202

# 2. Update hệ thống
apt-get update && apt-get upgrade -y

# 3. Cài Docker
curl -fsSL https://get.docker.com | sh

# 4. Vào thư mục code
cd /home/tradingview.com.vn

# 5. Sửa config (QUAN TRỌNG!)
nano config.docker.json
# Sửa 4 thứ:
# - "url": "https://tradingview.com.vn"
# - "database.connection.password": "đổi_password_mới"
# - "mail.options.auth": AWS SES credentials
# - "storage.s3": AWS S3 credentials
# Ctrl+O, Enter, Ctrl+X để lưu

# 6. Chạy script tự động
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh
# Script sẽ tự động build Docker, start containers, hỏi import database

# 7. Cài Nginx
apt-get install -y nginx

# 8. Tạo Nginx config (KHÔNG CẦN SSL - Cloudflare lo)
cat > /etc/nginx/sites-available/tradingview.com.vn << 'EOF'
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
    real_ip_header CF-Connecting-IP;

    location / {
        proxy_pass http://127.0.0.1:3005;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    client_max_body_size 50M;
}
EOF

# 9. Kích hoạt Nginx
ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# 10. Setup Firewall
apt-get install -y ufw
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable
```

---

## ☁️ Cấu hình Cloudflare

**Vào Cloudflare Dashboard:**

### 1. DNS Settings:
```
Type: A
Name: @
Content: 139.180.221.202
Proxy: ✅ ON (màu cam)

Type: A
Name: www
Content: 139.180.221.202
Proxy: ✅ ON (màu cam)
```

### 2. SSL/TLS Settings:
```
Mode: Full
Always Use HTTPS: ✅ ON
Automatic HTTPS Rewrites: ✅ ON
```

---

## ✅ Kiểm tra

```bash
# Kiểm tra containers
docker compose ps

# Xem logs
docker compose logs ghost

# Test local
curl http://localhost:3005
```

**Truy cập:** https://tradingview.com.vn

---

## 🛠️ Quản lý hàng ngày

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Restart
docker compose restart ghost

# Xem logs
docker compose logs -f ghost

# Backup database
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup.sql
```

---

## 🆘 Lỗi thường gặp

### Ghost không start
```bash
docker compose logs ghost
docker compose restart ghost
```

### Cloudflare Error 521
```bash
# Kiểm tra Nginx
systemctl status nginx
nginx -t

# Kiểm tra Ghost
docker compose ps
```

### Cloudflare Error 522
```bash
# Kiểm tra firewall mở port 80
ufw status

# Kiểm tra Nginx lắng nghe port 80
netstat -tulpn | grep :80
```

---

## 📚 Tài liệu chi tiết (nếu cần)

- **[SETUP_CLOUDFLARE_139.180.221.202.md](SETUP_CLOUDFLARE_139.180.221.202.md)** - Hướng dẫn chi tiết với Cloudflare
- **[SETUP_NHANH.md](SETUP_NHANH.md)** - Bản rút gọn
- **[SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)** - Hướng dẫn Docker đầy đủ

---

## 📌 Lưu ý quan trọng

- ✅ Domain dùng **Cloudflare SSL** → KHÔNG cần cài SSL trên server
- ✅ Server Ubuntu trắng → Chỉ cài: **Docker, Nginx, UFW**
- ✅ Nginx chỉ lắng nghe **port 80** (HTTP)
- ✅ Firewall chỉ mở **port 22, 80** (KHÔNG mở 443)
- ✅ Cloudflare lo phần HTTPS

---

**Chúc bạn setup thành công! 🎉**


