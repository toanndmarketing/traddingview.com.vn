# ✅ Checklist Setup Ghost CMS - Server 139.180.221.202

**Server:** 139.180.221.202  
**User:** root  
**Path:** /home/tradingview.com.vn  
**Ngày setup:** _______________

---

## 🎯 Chọn phương án

- [ ] Đã đọc [SETUP_GUIDE.md](SETUP_GUIDE.md)
- [ ] Đã chọn phương án: 
  - [ ] Docker (Khuyến nghị)
  - [ ] Non-Docker

---

## 🐳 Checklist Docker

### Chuẩn bị
- [ ] SSH vào server: `ssh root@139.180.221.202`
- [ ] Kiểm tra code tại: `/home/tradingview.com.vn`
- [ ] Kiểm tra Docker đã cài: `docker --version`
- [ ] Kiểm tra Docker Compose: `docker compose version`

### Cài đặt Docker (nếu chưa có)
- [ ] Chạy: `curl -fsSL https://get.docker.com -o get-docker.sh`
- [ ] Chạy: `sh get-docker.sh`
- [ ] Kiểm tra: `docker --version`

### Cấu hình
- [ ] Mở file: `nano config.docker.json`
- [ ] Sửa `url`: `https://tradingview.com.vn`
- [ ] Sửa `database.connection.password`: _______________
- [ ] Sửa `mail.options.auth.user`: _______________
- [ ] Sửa `mail.options.auth.pass`: _______________
- [ ] Sửa `storage.s3.accessKeyId`: _______________
- [ ] Sửa `storage.s3.secretAccessKey`: _______________
- [ ] Sửa `storage.s3.bucket`: _______________
- [ ] Sửa `storage.s3.assetHost`: _______________
- [ ] Lưu file: `Ctrl+O`, `Enter`, `Ctrl+X`

### Build và Start
- [ ] Chạy: `chmod +x scripts/docker-setup.sh`
- [ ] Chạy: `bash scripts/docker-setup.sh`
- [ ] Hoặc thủ công:
  - [ ] `docker compose build`
  - [ ] `docker compose up -d`
- [ ] Kiểm tra: `docker compose ps`
- [ ] Xem logs: `docker compose logs ghost`

### Import Database (nếu có)
- [ ] Giải nén: `gunzip database_new.sql.gz`
- [ ] Import: `docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < database_new.sql`
- [ ] Restart: `docker compose restart ghost`

### Setup Nginx
- [ ] Cài Nginx: `apt-get install -y nginx`
- [ ] Tạo config: `nano /etc/nginx/sites-available/tradingview.com.vn`
- [ ] Copy config từ hướng dẫn
- [ ] Kích hoạt: `ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/`
- [ ] Test: `nginx -t`
- [ ] Reload: `systemctl reload nginx`

### Setup SSL
- [ ] Cài Certbot: `apt-get install -y certbot python3-certbot-nginx`
- [ ] Lấy SSL: `certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn`

### Kiểm tra
- [ ] Test local: `curl http://localhost:3005`
- [ ] Truy cập: `https://tradingview.com.vn`
- [ ] Truy cập admin: `https://tradingview.com.vn/ghost`
- [ ] Tạo admin account
- [ ] Test upload ảnh (S3)
- [ ] Test gửi email

### Bảo mật
- [ ] Firewall: `ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp`
- [ ] Kích hoạt: `ufw enable`
- [ ] Kiểm tra: `ufw status`

### Backup
- [ ] Test backup: `docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > test_backup.sql`
- [ ] Setup cron backup tự động

---

## 🔧 Checklist Non-Docker

### Chuẩn bị
- [ ] SSH vào server: `ssh root@139.180.221.202`
- [ ] Kiểm tra code tại: `/home/tradingview.com.vn`

### Cài đặt Node.js
- [ ] Chạy: `curl -fsSL https://deb.nodesource.com/setup_18.x | bash -`
- [ ] Chạy: `apt-get install -y nodejs`
- [ ] Kiểm tra: `node -v` (phải >= 18.x)
- [ ] Kiểm tra: `npm -v`

### Cài đặt MySQL
- [ ] Chạy: `apt-get install -y mysql-server`
- [ ] Chạy: `mysql_secure_installation`
- [ ] Kiểm tra: `systemctl status mysql`

### Tạo Database
- [ ] Vào MySQL: `mysql -u root -p`
- [ ] Tạo database: `CREATE DATABASE ghost_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
- [ ] Tạo user: `CREATE USER 'ghost_user'@'localhost' IDENTIFIED BY 'password';`
- [ ] Cấp quyền: `GRANT ALL PRIVILEGES ON ghost_production.* TO 'ghost_user'@'localhost';`
- [ ] Flush: `FLUSH PRIVILEGES;`
- [ ] Thoát: `EXIT;`
- [ ] Password đã dùng: _______________

### Cài đặt Ghost
- [ ] Vào thư mục: `cd /home/tradingview.com.vn`
- [ ] Cấp quyền: `chmod +x scripts/*.sh`
- [ ] Chạy install: `bash scripts/install.sh`

### Cấu hình
- [ ] Mở file: `nano config.production.json`
- [ ] Sửa `url`: `https://tradingview.com.vn`
- [ ] Sửa `database.connection.user`: `ghost_user`
- [ ] Sửa `database.connection.password`: _______________
- [ ] Sửa `mail.options.auth.user`: _______________
- [ ] Sửa `mail.options.auth.pass`: _______________
- [ ] Sửa `storage.s3.accessKeyId`: _______________
- [ ] Sửa `storage.s3.secretAccessKey`: _______________
- [ ] Sửa `storage.s3.bucket`: _______________
- [ ] Sửa `storage.s3.assetHost`: _______________
- [ ] Sửa `paths.contentPath`: `/home/tradingview.com.vn/content`
- [ ] Lưu file: `Ctrl+O`, `Enter`, `Ctrl+X`
- [ ] Bảo mật: `chmod 600 config.production.json`

### Import Database (nếu có)
- [ ] Giải nén: `gunzip database_new.sql.gz`
- [ ] Import: `mysql -u ghost_user -p ghost_production < database_new.sql`

### Start Ghost
- [ ] Start: `pm2 start ecosystem.config.js`
- [ ] Hoặc: `bash scripts/ghost.sh start`
- [ ] Kiểm tra: `pm2 status`
- [ ] Xem logs: `pm2 logs ghost-tradingview`

### Setup PM2 Auto-start
- [ ] Lưu: `pm2 save`
- [ ] Setup: `pm2 startup`
- [ ] Copy và chạy lệnh mà PM2 hiển thị

### Setup Nginx
- [ ] Cài Nginx: `apt-get install -y nginx`
- [ ] Tạo config: `nano /etc/nginx/sites-available/tradingview.com.vn`
- [ ] Copy config từ hướng dẫn (port 2368)
- [ ] Kích hoạt: `ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/`
- [ ] Test: `nginx -t`
- [ ] Reload: `systemctl reload nginx`

### Setup SSL
- [ ] Cài Certbot: `apt-get install -y certbot python3-certbot-nginx`
- [ ] Lấy SSL: `certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn`

### Kiểm tra
- [ ] Test local: `curl http://localhost:2368`
- [ ] Truy cập: `https://tradingview.com.vn`
- [ ] Truy cập admin: `https://tradingview.com.vn/ghost`
- [ ] Tạo admin account
- [ ] Test upload ảnh (S3)
- [ ] Test gửi email

### Bảo mật
- [ ] Firewall: `ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp`
- [ ] Kích hoạt: `ufw enable`
- [ ] Kiểm tra: `ufw status`

### Backup
- [ ] Test backup: `bash scripts/backup-db.sh`
- [ ] Setup cron backup tự động

---

## 📝 Thông tin quan trọng

### Credentials
- **MySQL User:** _______________
- **MySQL Password:** _______________
- **AWS Access Key:** _______________
- **AWS Secret Key:** _______________
- **S3 Bucket:** _______________
- **SES User:** _______________
- **SES Password:** _______________

### URLs
- **Website:** https://tradingview.com.vn
- **Admin:** https://tradingview.com.vn/ghost
- **CDN:** _______________

### Ports
- **Ghost (Docker):** 3005
- **Ghost (Non-Docker):** 2368
- **MySQL:** 3306
- **Nginx:** 80, 443

---

## ✅ Hoàn tất

- [ ] Website hoạt động bình thường
- [ ] Admin panel truy cập được
- [ ] Upload ảnh hoạt động (S3)
- [ ] Gửi email hoạt động
- [ ] SSL certificate đã cài
- [ ] Backup tự động đã setup
- [ ] Firewall đã cấu hình
- [ ] PM2/Docker auto-start đã setup

---

**Ngày hoàn thành:** _______________  
**Người thực hiện:** _______________  
**Ghi chú:** _______________


