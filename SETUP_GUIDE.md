# 🚀 Hướng dẫn Setup Ghost CMS trên Server 139.180.221.202

**Server:** 139.180.221.202  
**User:** root  
**Code path:** /home/tradingview.com.vn

---

## 🎯 Chọn phương án setup

Bạn có **2 phương án** để setup Ghost CMS:

### 📦 Phương án 1: Docker (KHUYẾN NGHỊ ⭐)

**Ưu điểm:**
- ✅ Đơn giản, nhanh chóng (setup trong 10 phút)
- ✅ Không cần cài Node.js, MySQL thủ công
- ✅ Dễ quản lý, dễ backup, dễ rollback
- ✅ Độc lập, không ảnh hưởng hệ thống
- ✅ Tự động restart khi server reboot

**Nhược điểm:**
- ⚠️ Tốn RAM hơn một chút (~200MB)
- ⚠️ Cần hiểu cơ bản về Docker

**Phù hợp với:**
- Server đã có Docker
- Muốn setup nhanh
- Muốn dễ quản lý và bảo trì

👉 **[Xem hướng dẫn chi tiết: SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)**

---

### 🔧 Phương án 2: Cài đặt trực tiếp (Traditional)

**Ưu điểm:**
- ✅ Tối ưu resources hơn
- ✅ Kiểm soát chi tiết hơn
- ✅ Không cần Docker

**Nhược điểm:**
- ⚠️ Phức tạp hơn (nhiều bước)
- ⚠️ Phải cài Node.js, MySQL, PM2 thủ công
- ⚠️ Khó rollback khi có lỗi
- ⚠️ Ảnh hưởng đến hệ thống

**Phù hợp với:**
- Server không có Docker
- Muốn tối ưu resources
- Đã quen với Node.js, MySQL, PM2

👉 **[Xem hướng dẫn chi tiết: SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)**

---

## ⚡ Quick Start - Docker (10 phút)

```bash
# 1. SSH vào server
ssh root@139.180.221.202

# 2. Cài Docker (nếu chưa có)
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# 3. Vào thư mục code
cd /home/tradingview.com.vn

# 4. Cấu hình config.docker.json
nano config.docker.json
# Sửa: URL, AWS credentials, database password

# 5. Build và start
docker compose build
docker compose up -d

# 6. Import database (nếu có)
gunzip database_new.sql.gz
docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < database_new.sql

# 7. Cài Nginx
apt-get install -y nginx
nano /etc/nginx/sites-available/tradingview.com.vn
# Copy config từ hướng dẫn
ln -s /etc/nginx/sites-available/tradingview.com.vn /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 8. Cài SSL
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d tradingview.com.vn -d www.tradingview.com.vn

# 9. Truy cập
# https://tradingview.com.vn
```

---

## ⚡ Quick Start - Non-Docker (20 phút)

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
mysql -u root -p
CREATE DATABASE ghost_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'ghost_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON ghost_production.* TO 'ghost_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 5. Vào thư mục code
cd /home/tradingview.com.vn

# 6. Chạy install script
chmod +x scripts/*.sh
bash scripts/install.sh

# 7. Cấu hình config
nano config.production.json
# Sửa: URL, database, AWS credentials
chmod 600 config.production.json

# 8. Import database (nếu có)
gunzip database_new.sql.gz
mysql -u ghost_user -p ghost_production < database_new.sql

# 9. Start Ghost
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# 10. Cài Nginx và SSL (giống Docker)
```

---

## 📊 So sánh 2 phương án

| Tiêu chí | Docker | Non-Docker |
|----------|--------|------------|
| **Thời gian setup** | ⭐⭐⭐⭐⭐ 10 phút | ⭐⭐⭐ 20 phút |
| **Độ phức tạp** | ⭐⭐⭐⭐⭐ Đơn giản | ⭐⭐⭐ Trung bình |
| **Quản lý** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐⭐ Trung bình |
| **Backup/Restore** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐⭐ Trung bình |
| **Resources** | ⭐⭐⭐⭐ Tốt | ⭐⭐⭐⭐⭐ Rất tốt |
| **Isolation** | ⭐⭐⭐⭐⭐ Hoàn toàn | ⭐⭐ Không có |
| **Rollback** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐ Khó |

---

## 🎯 Khuyến nghị

### Dùng Docker nếu:
- ✅ Server đã có Docker
- ✅ Muốn setup nhanh
- ✅ Ưu tiên sự đơn giản và dễ quản lý
- ✅ Có nhiều services khác cũng chạy Docker
- ✅ Muốn dễ dàng backup/restore

### Dùng Non-Docker nếu:
- ✅ Server không có Docker và không muốn cài
- ✅ Muốn tối ưu resources tối đa
- ✅ Đã quen với Node.js, MySQL, PM2
- ✅ Cần kiểm soát chi tiết từng thành phần

---

## 📚 Tài liệu chi tiết

- **[SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)** - Hướng dẫn setup bằng Docker
- **[SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)** - Hướng dẫn setup trực tiếp
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Hướng dẫn deployment tổng quát
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start cho CloudPanel

---

## 🆘 Cần hỗ trợ?

Nếu gặp vấn đề trong quá trình setup:

1. Kiểm tra logs
2. Xem phần Troubleshooting trong hướng dẫn chi tiết
3. Liên hệ team support

---

**Chúc bạn setup thành công! 🎉**


