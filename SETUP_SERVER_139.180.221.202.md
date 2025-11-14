# 🚀 Hướng dẫn Setup Ghost CMS trên Server 139.180.221.202

**Server:** 139.180.221.202  
**User:** root  
**Code path:** /home/tradingview.com.vn

---

## 📋 Yêu cầu hệ thống

- ✅ Ubuntu 20.04/22.04/24.04
- ✅ Node.js v16.14+ hoặc v18.12+
- ✅ MySQL 5.7+ hoặc 8.0+
- ✅ Nginx
- ✅ PM2 (sẽ cài tự động)

---

## 🔧 Các bước Setup

### Bước 1: SSH vào server

```bash
ssh root@139.180.221.202
```

### Bước 2: Kiểm tra code đã clone

```bash
cd /home/tradingview.com.vn
ls -la
```

Nếu chưa có code, clone về:

```bash
cd /home
git clone <repository-url> tradingview.com.vn
cd tradingview.com.vn
```

### Bước 3: Cài đặt Node.js (nếu chưa có)

Kiểm tra Node.js:

```bash
node -v
npm -v
```

Nếu chưa có, cài đặt Node.js 18.x:

```bash
# Cài đặt Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Kiểm tra lại
node -v
npm -v
```

### Bước 4: Cài đặt MySQL (nếu chưa có)

```bash
# Cài đặt MySQL
apt-get update
apt-get install -y mysql-server

# Khởi động MySQL
systemctl start mysql
systemctl enable mysql

# Bảo mật MySQL
mysql_secure_installation
```

### Bước 5: Tạo Database

```bash
mysql -u root -p
```

Trong MySQL console:

```sql
-- Tạo database
CREATE DATABASE ghost_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Tạo user
CREATE USER 'ghost_user'@'localhost' IDENTIFIED BY 'your_strong_password_here';

-- Cấp quyền
GRANT ALL PRIVILEGES ON ghost_production.* TO 'ghost_user'@'localhost';
FLUSH PRIVILEGES;

-- Kiểm tra
SHOW DATABASES;
EXIT;
```

### Bước 6: Chạy script cài đặt

```bash
cd /home/tradingview.com.vn

# Cấp quyền cho scripts
chmod +x scripts/*.sh

# Chạy install
bash scripts/install.sh
```

Script sẽ tự động:
- ✅ Cài đặt dependencies
- ✅ Download Ghost core v5.58.0
- ✅ Setup S3 storage adapter
- ✅ Tạo thư mục cần thiết
- ✅ Tạo config template
- ✅ Cài đặt PM2

### Bước 7: Cấu hình config.production.json

```bash
nano config.production.json
```

Chỉnh sửa các thông tin sau:

```json
{
  "url": "https://tradingview.com.vn",
  "server": {
    "port": 2368,
    "host": "127.0.0.1"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "127.0.0.1",
      "user": "ghost_user",
      "password": "your_strong_password_here",
      "port": 3306,
      "database": "ghost_production"
    }
  },
  "mail": {
    "transport": "SMTP",
    "options": {
      "host": "email-smtp.ap-southeast-1.amazonaws.com",
      "port": 465,
      "service": "SES",
      "auth": {
        "user": "YOUR_AWS_SES_USER",
        "pass": "YOUR_AWS_SES_PASSWORD"
      }
    },
    "from": "'TradingView Vietnam' <noreply@tradingview.com.vn>"
  },
  "logging": {
    "transports": ["file", "stdout"]
  },
  "process": "systemd",
  "paths": {
    "contentPath": "/home/tradingview.com.vn/content"
  },
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "YOUR_AWS_ACCESS_KEY_ID",
      "secretAccessKey": "YOUR_AWS_SECRET_ACCESS_KEY",
      "region": "ap-southeast-1",
      "bucket": "your-bucket-name",
      "assetHost": "https://your-cdn-url.com",
      "forcePathStyle": true,
      "signatureVersion": "v4",
      "acl": "private"
    }
  }
}
```

**Lưu file:** `Ctrl+O` → `Enter` → `Ctrl+X`

**Bảo mật config:**

```bash
chmod 600 config.production.json
```

### Bước 8: Import Database (nếu có backup)

Nếu bạn có file backup database:

```bash
cd /home/tradingview.com.vn

# Nếu file .sql.gz
gunzip database_new.sql.gz

# Import vào database
mysql -u ghost_user -p ghost_production < database_new.sql
```

### Bước 9: Khởi động Ghost

```bash
cd /home/tradingview.com.vn

# Start Ghost bằng PM2
pm2 start ecosystem.config.js

# Hoặc dùng script
bash scripts/ghost.sh start

# Xem logs
pm2 logs ghost-tradingview

# Kiểm tra status
pm2 status
```

### Bước 10: Lưu PM2 process (tự động khởi động khi reboot)

```bash
# Lưu PM2 process list
pm2 save

# Setup PM2 startup
pm2 startup

# Copy và chạy lệnh mà PM2 hiển thị
# Ví dụ: sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root
```

### Bước 11: Cài đặt và cấu hình Nginx

```bash
# Cài đặt Nginx (nếu chưa có)
apt-get install -y nginx

# Tạo file config cho site
nano /etc/nginx/sites-available/tradingview.com.vn
```

Nội dung file Nginx config:

```nginx
server {
    listen 80;
    server_name tradingview.com.vn www.tradingview.com.vn;

    # Redirect to HTTPS (sau khi có SSL)
    # return 301 https://$server_name$request_uri;

    location / {
        proxy_pass http://127.0.0.1:2368;
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

### Bước 12: Cài đặt SSL với Let's Encrypt

```bash
# Cài đặt Certbot
apt-get install -y certbot python3-certbot-nginx

# Lấy SSL certificate
certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn

# Certbot sẽ tự động cấu hình Nginx và redirect HTTP -> HTTPS
```

### Bước 13: Cấu hình Firewall

```bash
# Cho phép SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Kích hoạt firewall
ufw enable

# Kiểm tra status
ufw status
```

---

## ✅ Kiểm tra hoạt động

### 1. Kiểm tra Ghost đang chạy

```bash
pm2 status
pm2 logs ghost-tradingview
```

### 2. Kiểm tra port

```bash
netstat -tulpn | grep 2368
# Hoặc
ss -tulpn | grep 2368
```

### 3. Test local

```bash
curl http://127.0.0.1:2368
```

### 4. Truy cập website

- Frontend: `https://tradingview.com.vn`
- Admin: `https://tradingview.com.vn/ghost`

---

## 🛠️ Các lệnh quản lý Ghost

```bash
cd /home/tradingview.com.vn

# Start Ghost
bash scripts/ghost.sh start

# Stop Ghost
bash scripts/ghost.sh stop

# Restart Ghost
bash scripts/ghost.sh restart

# Xem status
bash scripts/ghost.sh status

# Xem logs realtime
bash scripts/ghost.sh logs

# Hoặc dùng PM2 trực tiếp
pm2 start ghost-tradingview
pm2 stop ghost-tradingview
pm2 restart ghost-tradingview
pm2 logs ghost-tradingview
pm2 monit
```

---

## 🔄 Backup & Update

### Backup Database

```bash
cd /home/tradingview.com.vn
bash scripts/backup-db.sh
```

### Update Code

```bash
cd /home/tradingview.com.vn
bash scripts/update.sh
```

### Rollback khi có lỗi

```bash
cd /home/tradingview.com.vn
bash scripts/rollback.sh
```

---

## 🐛 Troubleshooting

### Ghost không start được

```bash
# Xem logs chi tiết
pm2 logs ghost-tradingview --lines 100

# Xem error logs
cat content/logs/pm2-error.log

# Kiểm tra config
cat config.production.json

# Test MySQL connection
mysql -u ghost_user -p -h 127.0.0.1 ghost_production
```

### Lỗi port đã được sử dụng

```bash
# Kiểm tra process đang dùng port 2368
lsof -i :2368

# Kill process
kill -9 <PID>

# Hoặc stop Ghost và start lại
pm2 stop ghost-tradingview
pm2 start ghost-tradingview
```

### Lỗi permissions

```bash
cd /home/tradingview.com.vn

# Fix permissions
chmod -R 755 content/
chown -R root:root .

# Config file phải 600
chmod 600 config.production.json
```

### Lỗi MySQL connection

```bash
# Kiểm tra MySQL đang chạy
systemctl status mysql

# Restart MySQL
systemctl restart mysql

# Kiểm tra user và password
mysql -u ghost_user -p
```

### Lỗi S3 upload

- Kiểm tra AWS credentials trong `config.production.json`
- Kiểm tra bucket permissions
- Kiểm tra network connectivity: `ping s3.ap-southeast-1.amazonaws.com`

---

## 📊 Monitoring

### Xem resource usage

```bash
# PM2 monitoring
pm2 monit

# System resources
htop
# hoặc
top

# Disk usage
df -h

# Memory usage
free -h
```

### Setup log rotation

```bash
# PM2 log rotation
pm2 install pm2-logrotate

# Cấu hình
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
```

---

## 🔐 Bảo mật

### 1. Đổi password MySQL

```bash
mysql -u root -p
ALTER USER 'ghost_user'@'localhost' IDENTIFIED BY 'new_strong_password';
FLUSH PRIVILEGES;
EXIT;

# Cập nhật config.production.json
nano config.production.json
```

### 2. Bảo vệ file config

```bash
chmod 600 config.production.json
chown root:root config.production.json
```

### 3. Disable root login SSH (khuyến nghị)

```bash
# Tạo user mới trước
adduser deploy
usermod -aG sudo deploy

# Sau đó disable root login
nano /etc/ssh/sshd_config
# Sửa: PermitRootLogin no

systemctl restart sshd
```

### 4. Cài đặt fail2ban

```bash
apt-get install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:

1. **Logs:** `pm2 logs ghost-tradingview`
2. **Status:** `pm2 status`
3. **MySQL:** `systemctl status mysql`
4. **Nginx:** `systemctl status nginx`
5. **Firewall:** `ufw status`

---

## 📝 Checklist hoàn chỉnh

- [ ] SSH vào server 139.180.221.202
- [ ] Kiểm tra code tại /home/tradingview.com.vn
- [ ] Cài đặt Node.js 18.x
- [ ] Cài đặt MySQL
- [ ] Tạo database và user
- [ ] Chạy `bash scripts/install.sh`
- [ ] Cấu hình `config.production.json`
- [ ] Import database (nếu có)
- [ ] Start Ghost với PM2
- [ ] Cấu hình Nginx
- [ ] Cài đặt SSL
- [ ] Cấu hình Firewall
- [ ] Test website
- [ ] Setup PM2 startup
- [ ] Setup backup tự động

---

**Chúc bạn setup thành công! 🎉**

Nếu cần hỗ trợ, hãy kiểm tra logs và các file hướng dẫn khác:
- `DEPLOYMENT.md` - Chi tiết về deployment
- `QUICKSTART.md` - Hướng dẫn nhanh
- `scripts/README.md` - Hướng dẫn về scripts


