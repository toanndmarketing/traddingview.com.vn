# 🚀 Hướng dẫn Deploy Ghost CMS

## 📋 Checklist trước khi deploy

- [ ] Node.js v16.14+ hoặc v18.12+ đã được cài đặt
- [ ] MySQL 5.7+ hoặc 8.0+ đã được cài đặt và chạy
- [ ] Database `ghost_production` đã được tạo
- [ ] AWS S3 bucket đã được setup
- [ ] AWS SES đã được cấu hình (nếu dùng email)
- [ ] Domain đã được trỏ về server

## 🔧 Các bước Deploy

### 1. Clone repository

```bash
git clone <repository-url>
cd tradingview.com.vn
```

### 2. Cài đặt Ghost Core

```bash
# Download Ghost v5.58.0
npm install ghost@5.58.0 --save

# Hoặc copy từ backup
# cp -r /backup/versions ./
```

### 3. Cài đặt dependencies

```bash
npm install
```

### 4. Cấu hình

Tạo file `config.production.json`:

```bash
cp config.example.json config.production.json
```

Chỉnh sửa `config.production.json` với thông tin thực tế:
- Database credentials
- AWS S3 credentials
- AWS SES credentials
- Domain URL
- Content path

### 5. Setup Storage Adapter

```bash
# Copy S3 adapter vào content/adapters
mkdir -p content/adapters/storage
cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3
```

### 6. Import Database (nếu có backup)

```bash
mysql -u ghost-814 -p ghost_production < backup.sql
```

### 7. Chạy Ghost

#### Development:
```bash
NODE_ENV=development node versions/5.58.0/index.js
```

#### Production với PM2:
```bash
# Cài đặt PM2
npm install -g pm2

# Tạo file ecosystem.config.js
pm2 start ecosystem.config.js

# Lưu PM2 process
pm2 save
pm2 startup
```

### 8. Setup Nginx (Production)

```nginx
server {
    listen 80;
    server_name tradingview.com.vn;

    location / {
        proxy_pass http://127.0.0.1:2366;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 9. Setup SSL với Let's Encrypt

```bash
sudo certbot --nginx -d tradingview.com.vn
```

## 🔄 Update Ghost

```bash
# Backup database trước
mysqldump -u ghost-814 -p ghost_production > backup_$(date +%Y%m%d).sql

# Pull code mới
git pull origin main

# Cài đặt dependencies
npm install

# Restart Ghost
pm2 restart ghost
```

## 📊 Monitoring

```bash
# Xem logs
pm2 logs ghost

# Xem status
pm2 status

# Restart
pm2 restart ghost

# Stop
pm2 stop ghost
```

## 🔐 Bảo mật

1. **Firewall**: Chỉ mở port 80, 443, 22
2. **Database**: Không expose MySQL ra ngoài
3. **Config files**: Đảm bảo `config.production.json` có quyền 600
4. **SSL**: Luôn dùng HTTPS
5. **Backup**: Backup database hàng ngày

## 🆘 Troubleshooting

### Ghost không start được

```bash
# Check logs
pm2 logs ghost

# Check MySQL connection
mysql -u ghost-814 -p -h 127.0.0.1

# Check port
netstat -tulpn | grep 2366
```

### Lỗi S3 upload

- Kiểm tra AWS credentials
- Kiểm tra bucket permissions
- Kiểm tra network connectivity

### Lỗi email

- Kiểm tra AWS SES credentials
- Kiểm tra SES sending limits
- Verify email addresses trong SES

## 📞 Support

- Ghost Docs: https://ghost.org/docs/
- Ghost Forum: https://forum.ghost.org/

