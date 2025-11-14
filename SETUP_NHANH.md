# ⚡ SETUP NHANH - 10 PHÚT

**Server:** 139.180.221.202 | **Domain:** tradingview.com.vn (Cloudflare SSL)

---

## 🚀 Copy & Paste (10 lệnh)

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
# Sửa: url, database password, AWS credentials
# Ctrl+O, Enter, Ctrl+X

# 6. Chạy script tự động
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh

# 7. Cài Nginx
apt-get install -y nginx

# 8. Tạo Nginx config
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

### DNS:
- Type: `A`, Name: `@`, Content: `139.180.221.202`, Proxy: ✅ **ON** (màu cam)
- Type: `A`, Name: `www`, Content: `139.180.221.202`, Proxy: ✅ **ON** (màu cam)

### SSL/TLS:
- Mode: **Full**
- Always Use HTTPS: ✅ **ON**

---

## ✅ Kiểm tra

```bash
# Kiểm tra containers
docker compose ps

# Kiểm tra logs
docker compose logs ghost

# Test
curl http://localhost:3005
```

**Truy cập:** https://tradingview.com.vn

---

## 📝 Cần sửa trong config.docker.json

```json
{
  "url": "https://tradingview.com.vn",
  "database": {
    "connection": {
      "password": "ĐỔI_PASSWORD_MỚI"
    }
  },
  "mail": {
    "options": {
      "auth": {
        "user": "AWS_SES_USER",
        "pass": "AWS_SES_PASSWORD"
      }
    }
  },
  "storage": {
    "s3": {
      "accessKeyId": "AWS_ACCESS_KEY",
      "secretAccessKey": "AWS_SECRET_KEY",
      "bucket": "TÊN_BUCKET",
      "assetHost": "https://cdn.tradingview.com.vn"
    }
  }
}
```

---

## 🛠️ Quản lý

```bash
docker compose up -d      # Start
docker compose down       # Stop
docker compose restart    # Restart
docker compose logs -f    # Logs
```

---

## 🆘 Lỗi?

```bash
# Xem logs
docker compose logs ghost

# Restart
docker compose restart ghost

# Kiểm tra Nginx
nginx -t
systemctl status nginx
```

---

**Chi tiết:** [SETUP_CLOUDFLARE_139.180.221.202.md](SETUP_CLOUDFLARE_139.180.221.202.md)


