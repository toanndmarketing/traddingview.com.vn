# ☁️ Setup Ghost CMS với Cloudflare SSL

**Server:** 139.180.221.202 (Ubuntu trắng)  
**Domain:** tradingview.com.vn (Cloudflare SSL đã bật)  
**Path:** /home/tradingview.com.vn

---

## 🎯 Điểm khác biệt

### ✅ Có Cloudflare SSL:
- **KHÔNG** cần cài Certbot/Let's Encrypt
- **KHÔNG** cần cài SSL certificate trên server
- Nginx chỉ lắng nghe **port 80** (HTTP)
- Cloudflare lo phần HTTPS

### ✅ Server Ubuntu trắng:
- Chỉ cần cài: **Docker, Nginx, UFW**
- Không cần: Node.js, MySQL, PM2 (đã có trong Docker)

---

## ⚡ Setup nhanh (10 phút)

👉 **Đọc:** [SETUP_NHANH.md](SETUP_NHANH.md)

```bash
ssh root@139.180.221.202
cd /home/tradingview.com.vn
bash scripts/docker-setup.sh
```

---

## 📚 Tài liệu

| File | Mô tả |
|------|-------|
| **[SETUP_NHANH.md](SETUP_NHANH.md)** | ⚡ 10 lệnh, 10 phút |
| **[SETUP_CLOUDFLARE_139.180.221.202.md](SETUP_CLOUDFLARE_139.180.221.202.md)** | ☁️ Hướng dẫn chi tiết với Cloudflare |
| **[START_HERE.md](START_HERE.md)** | 🚀 Điểm bắt đầu |

---

## 🔧 Cài đặt trên server

### Chỉ cần 3 thứ:

1. **Docker** - Chạy Ghost, MySQL, Redis
2. **Nginx** - Reverse proxy (port 80)
3. **UFW** - Firewall (chỉ mở port 22, 80)

**KHÔNG cần:**
- ❌ Certbot/Let's Encrypt
- ❌ Node.js
- ❌ MySQL
- ❌ PM2
- ❌ Port 443

---

## ☁️ Cấu hình Cloudflare

### DNS:
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

### SSL/TLS:
```
Mode: Full
Always Use HTTPS: ✅ ON
Automatic HTTPS Rewrites: ✅ ON
```

---

## 🔥 Nginx Config

```nginx
server {
    listen 80;
    server_name tradingview.com.vn www.tradingview.com.vn;

    # Cloudflare Real IP
    set_real_ip_from 173.245.48.0/20;
    # ... (xem đầy đủ trong SETUP_NHANH.md)
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
```

**Lưu ý:** Chỉ lắng nghe port 80, KHÔNG có SSL!

---

## 🔐 Firewall

```bash
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP (cho Cloudflare)
# KHÔNG mở port 443 (SSL ở Cloudflare)
ufw enable
```

---

## ✅ Luồng hoạt động

```
User
  ↓ HTTPS (443)
Cloudflare (SSL Termination)
  ↓ HTTP (80)
Nginx (139.180.221.202:80)
  ↓ HTTP (3005)
Ghost Container (127.0.0.1:3005)
```

---

## 🆘 Lỗi thường gặp

### Cloudflare Error 521 (Web server is down)
```bash
# Kiểm tra Nginx
systemctl status nginx

# Kiểm tra Ghost
docker compose ps
```

### Cloudflare Error 522 (Connection timed out)
```bash
# Kiểm tra firewall mở port 80
ufw status

# Kiểm tra Nginx lắng nghe port 80
netstat -tulpn | grep :80
```

### Redirect loop (Too many redirects)
```bash
# Kiểm tra Cloudflare SSL mode = Full (không phải Flexible)
# Kiểm tra Ghost config.docker.json có url = https://...
```

---

## 📋 Checklist

- [ ] Cài Docker
- [ ] Chạy `bash scripts/docker-setup.sh`
- [ ] Cài Nginx (chỉ port 80)
- [ ] Cấu hình Cloudflare DNS (Proxied ON)
- [ ] Cấu hình Cloudflare SSL (Full mode)
- [ ] Setup Firewall (port 22, 80)
- [ ] Test: https://tradingview.com.vn

---

**Chúc bạn setup thành công! 🎉**


