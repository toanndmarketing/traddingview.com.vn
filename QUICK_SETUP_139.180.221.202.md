# ⚡ Quick Setup - Server 139.180.221.202

**Hướng dẫn setup nhanh nhất cho server 139.180.221.202**

---

## 🐳 Phương án 1: Docker (5 lệnh - 10 phút)

```bash
# 1. SSH vào server
ssh root@139.180.221.202

# 2. Vào thư mục code
cd /home/tradingview.com.vn

# 3. Chỉnh sửa config (quan trọng!)
nano config.docker.json
# Sửa: url, AWS credentials, database password
# Ctrl+O, Enter, Ctrl+X để lưu

# 4. Chạy script tự động
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh

# 5. Setup Nginx + SSL
apt-get install -y nginx certbot python3-certbot-nginx

# Tạo Nginx config
cat > /etc/nginx/sites-available/tradingview.com.vn << 'EOF'
server {
    listen 80;
    server_name tradingview.com.vn www.tradingview.com.vn;
    
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

# Kích hoạt site
ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Cài SSL
certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn

# ✅ XONG! Truy cập: https://tradingview.com.vn
```

---

## 🔧 Phương án 2: Non-Docker (10 lệnh - 20 phút)

```bash
# 1. SSH vào server
ssh root@139.180.221.202

# 2. Cài Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 3. Cài MySQL
apt-get install -y mysql-server
mysql_secure_installation

# 4. Tạo database
mysql -u root -p << 'EOF'
CREATE DATABASE ghost_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'ghost_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON ghost_production.* TO 'ghost_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# 5. Vào thư mục code
cd /home/tradingview.com.vn

# 6. Chạy install script
chmod +x scripts/*.sh
bash scripts/install.sh

# 7. Chỉnh sửa config
nano config.production.json
# Sửa: url, database credentials, AWS credentials
# Ctrl+O, Enter, Ctrl+X để lưu
chmod 600 config.production.json

# 8. Import database (nếu có)
gunzip database_new.sql.gz
mysql -u ghost_user -p ghost_production < database_new.sql

# 9. Start Ghost
pm2 start ecosystem.config.js
pm2 save
pm2 startup
# Copy và chạy lệnh mà PM2 hiển thị

# 10. Setup Nginx + SSL (giống Docker)
# ... (copy từ phần Docker ở trên)

# ✅ XONG! Truy cập: https://tradingview.com.vn
```

---

## 📋 Import Database (nếu có backup)

### Docker:
```bash
cd /home/tradingview.com.vn
gunzip database_new.sql.gz
docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < database_new.sql
docker compose restart ghost
```

### Non-Docker:
```bash
cd /home/tradingview.com.vn
gunzip database_new.sql.gz
mysql -u ghost_user -p ghost_production < database_new.sql
pm2 restart ghost-tradingview
```

---

## 🔍 Kiểm tra

```bash
# Docker
docker compose ps
docker compose logs ghost
curl http://localhost:3005

# Non-Docker
pm2 status
pm2 logs ghost-tradingview
curl http://localhost:2368
```

---

## 🛠️ Quản lý

### Docker:
```bash
docker compose up -d      # Start
docker compose down       # Stop
docker compose restart    # Restart
docker compose logs -f    # Logs
```

### Non-Docker:
```bash
pm2 start ghost-tradingview    # Start
pm2 stop ghost-tradingview     # Stop
pm2 restart ghost-tradingview  # Restart
pm2 logs ghost-tradingview     # Logs
```

---

## 🆘 Lỗi thường gặp

### Docker không start
```bash
docker compose logs ghost
docker compose restart ghost
```

### Ghost không start (Non-Docker)
```bash
pm2 logs ghost-tradingview
pm2 restart ghost-tradingview
```

### Lỗi MySQL connection
```bash
# Docker
docker compose logs mysql
docker compose restart mysql

# Non-Docker
systemctl status mysql
systemctl restart mysql
```

### Port đã được sử dụng
```bash
# Kiểm tra port
netstat -tulpn | grep 3005  # Docker
netstat -tulpn | grep 2368  # Non-Docker

# Kill process
kill -9 <PID>
```

---

## 📞 Cần hỗ trợ chi tiết?

- **Docker:** [SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)
- **Non-Docker:** [SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)
- **Chọn phương án:** [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

**Khuyến nghị:** Dùng Docker nếu server đã có Docker! 🐳


