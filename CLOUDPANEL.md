# 🚀 Hướng dẫn Deploy Ghost CMS trên CloudPanel Ubuntu 24

## 📋 Yêu cầu

- ✅ CloudPanel đã cài đặt
- ✅ Site đã được tạo với Node.js 18
- ✅ MySQL database đã được tạo
- ✅ SSH access vào server

---

## 🎯 Các bước Deploy

### Bước 1: SSH vào server

```bash
ssh clp@your-server-ip
```

### Bước 2: Di chuyển vào thư mục site

```bash
cd /home/clp/htdocs/your-domain.com
```

### Bước 3: Clone repository

```bash
# Xóa file mặc định (nếu có)
rm -rf *
rm -rf .* 2>/dev/null || true

# Clone repository
git clone git@github.com:toanndmarketing/traddingview.com.vn.git .
```

**Lưu ý:** Nếu chưa setup SSH key cho GitHub:

```bash
# Tạo SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Thêm key vào GitHub: Settings > SSH and GPG keys > New SSH key
```

### Bước 4: Chạy script cài đặt

```bash
# Cấp quyền execute
chmod +x scripts/*.sh

# Chạy install script
bash scripts/install.sh
```

Script sẽ tự động:
- ✅ Kiểm tra Node.js và npm
- ✅ Cài đặt dependencies
- ✅ Download Ghost core v5.58.0
- ✅ Setup S3 storage adapter
- ✅ Tạo thư mục cần thiết
- ✅ Cài đặt PM2
- ✅ Tạo config files

### Bước 5: Cấu hình config.production.json

```bash
# Mở file config
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
      "user": "your-db-user",
      "password": "your-db-password",
      "port": 3306,
      "database": "your-db-name"
    }
  },
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "YOUR_AWS_ACCESS_KEY",
      "secretAccessKey": "YOUR_AWS_SECRET_KEY",
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

**Lưu file:** `Ctrl + O`, `Enter`, `Ctrl + X`

### Bước 6: Khởi động Ghost

```bash
# Start Ghost
bash scripts/ghost.sh start

# Hoặc dùng PM2 trực tiếp
pm2 start ecosystem.config.js
```

### Bước 7: Kiểm tra status

```bash
# Xem status
bash scripts/ghost.sh status

# Xem logs
bash scripts/ghost.sh logs
```

### Bước 8: Lưu PM2 process

```bash
# Lưu PM2 process list
pm2 save

# Setup PM2 auto-start khi reboot
pm2 startup
# Copy và chạy lệnh được hiển thị
```

### Bước 9: Cấu hình Reverse Proxy trong CloudPanel

1. Đăng nhập vào CloudPanel
2. Vào **Sites** > Chọn site của bạn
3. Vào tab **Vhost**
4. Thêm cấu hình reverse proxy:

```nginx
location / {
    proxy_pass http://127.0.0.1:2368;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    
    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
}

# Cache static files
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    proxy_pass http://127.0.0.1:2368;
    proxy_set_header Host $host;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

5. Click **Save**

### Bước 10: Truy cập website

```
https://your-domain.com
https://your-domain.com/ghost (Admin panel)
```

---

## 🔄 Update Code Mới

Khi có code mới trên Git:

```bash
cd /home/clp/htdocs/your-domain.com

# Chạy update script
bash scripts/update.sh
```

Script sẽ tự động:
- ✅ Backup database
- ✅ Stop Ghost
- ✅ Pull code mới
- ✅ Update dependencies
- ✅ Restart Ghost

---

## 🛠️ Các lệnh hữu ích

### Quản lý Ghost

```bash
# Start Ghost
bash scripts/ghost.sh start

# Stop Ghost
bash scripts/ghost.sh stop

# Restart Ghost
bash scripts/ghost.sh restart

# Reload Ghost (zero-downtime)
bash scripts/ghost.sh reload

# Xem status
bash scripts/ghost.sh status

# Xem logs
bash scripts/ghost.sh logs
```

### PM2 Commands

```bash
# List processes
pm2 list

# Xem logs
pm2 logs ghost-tradingview

# Restart
pm2 restart ghost-tradingview

# Stop
pm2 stop ghost-tradingview

# Delete process
pm2 delete ghost-tradingview

# Monitor
pm2 monit
```

### Database

```bash
# Backup database
bash scripts/backup-db.sh

# Restore database
bash scripts/rollback.sh
```

---

## 🐛 Troubleshooting

### Ghost không start

```bash
# Xem logs chi tiết
pm2 logs ghost-tradingview --lines 100

# Kiểm tra config
cat config.production.json

# Test database connection
mysql -u username -p -h localhost database_name
```

### Lỗi permissions

```bash
# Fix permissions
chmod -R 755 content/
chown -R clp:clp content/
```

### Port đã được sử dụng

```bash
# Kiểm tra port
netstat -tulpn | grep 2368

# Kill process
kill -9 <PID>
```

### Ghost bị crash

```bash
# Xem logs
pm2 logs ghost-tradingview

# Restart
pm2 restart ghost-tradingview

# Nếu vẫn lỗi, xóa và start lại
pm2 delete ghost-tradingview
pm2 start ecosystem.config.js
```

---

## 📊 Monitoring

### Xem resource usage

```bash
pm2 monit
```

### Xem logs realtime

```bash
pm2 logs ghost-tradingview --lines 50
```

### Xem thông tin chi tiết

```bash
pm2 describe ghost-tradingview
```

---

## 🔐 Bảo mật

1. **Không commit config.production.json** lên Git
2. **Backup database thường xuyên**
3. **Update Ghost và dependencies định kỳ**
4. **Sử dụng SSL certificate** (CloudPanel tự động với Let's Encrypt)
5. **Giới hạn quyền truy cập SSH**

---

## 📞 Support

- **GitHub:** https://github.com/toanndmarketing/traddingview.com.vn
- **Ghost Docs:** https://ghost.org/docs/
- **CloudPanel Docs:** https://www.cloudpanel.io/docs/

---

## ✅ Checklist

- [ ] SSH vào server
- [ ] Clone repository
- [ ] Chạy `bash scripts/install.sh`
- [ ] Chỉnh sửa `config.production.json`
- [ ] Start Ghost: `bash scripts/ghost.sh start`
- [ ] Cấu hình reverse proxy trong CloudPanel
- [ ] Setup SSL certificate
- [ ] Truy cập website và admin panel
- [ ] Tạo tài khoản admin đầu tiên
- [ ] Setup PM2 auto-start: `pm2 save && pm2 startup`

