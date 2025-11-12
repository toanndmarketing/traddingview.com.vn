# 🚀 Ghost CMS - Deployment Scripts

Các script tự động hóa việc deploy, update và quản lý Ghost CMS.

## 📋 Danh sách Scripts

### 1. `deploy.sh` - Deploy một lần (First Deploy)
Script chính để deploy Ghost CMS lên server mới.

**Sử dụng:**
```bash
bash scripts/deploy.sh
```

**Chức năng:**
- ✅ Cài đặt Node.js, MySQL (nếu chưa có)
- ✅ Tạo file config tự động
- ✅ Cài đặt dependencies
- ✅ Download Ghost core
- ✅ Setup PM2
- ✅ Setup Nginx (optional)
- ✅ Khởi động Ghost

---

### 2. `setup.sh` - Setup Ghost CMS
Setup Ghost CMS từ đầu (không bao gồm Nginx).

**Sử dụng:**
```bash
bash scripts/setup.sh
```

**Chức năng:**
- Kiểm tra và cài đặt Node.js
- Kiểm tra MySQL
- Tạo config.production.json
- Cài đặt dependencies
- Download Ghost core
- Setup S3 adapter
- Tạo thư mục cần thiết
- Setup PM2

---

### 3. `update.sh` - Update Ghost CMS
Update code mới từ Git và restart Ghost.

**Sử dụng:**
```bash
bash scripts/update.sh
```

**Chức năng:**
- ✅ Backup database tự động
- ✅ Backup config files
- ✅ Stop Ghost
- ✅ Pull code mới từ Git
- ✅ Update dependencies
- ✅ Run migrations
- ✅ Restart Ghost
- ✅ Verify Ghost đang chạy

**Lưu ý:**
- Tự động backup database trước khi update
- Giữ lại 7 bản backup gần nhất
- Tự động rollback nếu có lỗi

---

### 4. `rollback.sh` - Rollback về version trước
Rollback database và code về version trước khi có lỗi.

**Sử dụng:**
```bash
bash scripts/rollback.sh
```

**Chức năng:**
- Hiển thị danh sách backups
- Restore database từ backup
- Rollback Git code (optional)
- Restart Ghost

---

### 5. `setup-nginx.sh` - Setup Nginx
Cấu hình Nginx làm reverse proxy cho Ghost.

**Sử dụng:**
```bash
sudo bash scripts/setup-nginx.sh
```

**Chức năng:**
- Cài đặt Nginx
- Tạo config cho domain
- Setup SSL với Let's Encrypt
- Enable auto-renewal SSL

---

## 🎯 Workflow Deploy

### Deploy lần đầu (Fresh Server)

```bash
# 1. Clone repository
git clone git@github.com:toanndmarketing/traddingview.com.vn.git
cd traddingview.com.vn

# 2. Chạy deploy script
bash scripts/deploy.sh

# 3. Truy cập và setup admin
# http://your-domain.com/ghost
```

### Update code mới

```bash
# 1. SSH vào server
ssh user@your-server

# 2. Chạy update script
cd /path/to/tradingview.com.vn
bash scripts/update.sh

# 3. Kiểm tra logs
pm2 logs ghost-tradingview
```

### Rollback khi có lỗi

```bash
# 1. Chạy rollback script
bash scripts/rollback.sh

# 2. Chọn backup muốn restore
# 3. Confirm và đợi hoàn tất
```

---

## 📁 Cấu trúc Backup

```
backups/
├── ghost_backup_20241112_100000.sql.gz
├── ghost_backup_20241112_110000.sql.gz
└── ghost_backup_20241112_120000.sql.gz
```

- Backup tự động khi chạy `update.sh`
- Giữ lại 7 bản backup gần nhất
- Format: `ghost_backup_YYYYMMDD_HHMMSS.sql.gz`

---

## ⚙️ Yêu cầu hệ thống

- **OS:** Ubuntu 20.04+ / Debian 10+
- **Node.js:** v16.14+ hoặc v18.12+
- **MySQL:** 5.7+ hoặc 8.0+
- **RAM:** Tối thiểu 1GB
- **Disk:** Tối thiểu 2GB

---

## 🔧 Troubleshooting

### Script không chạy được

```bash
# Cấp quyền execute
chmod +x scripts/*.sh

# Chạy lại
bash scripts/deploy.sh
```

### Lỗi database connection

```bash
# Kiểm tra MySQL
sudo systemctl status mysql

# Test connection
mysql -u username -p -h localhost
```

### Ghost không start

```bash
# Xem logs
pm2 logs ghost-tradingview

# Restart
pm2 restart ghost-tradingview

# Xem chi tiết
pm2 describe ghost-tradingview
```

### Lỗi permissions

```bash
# Fix permissions
chmod -R 755 content/
chown -R $USER:$USER content/
```

---

## 📞 Support

- **Documentation:** [README.md](../README.md)
- **Deployment Guide:** [DEPLOYMENT.md](../DEPLOYMENT.md)
- **Ghost Docs:** https://ghost.org/docs/

---

## 🔐 Bảo mật

- ⚠️ **KHÔNG** commit file `config.production.json`
- ⚠️ Backup files chứa sensitive data
- ⚠️ Giữ scripts trong thư mục có quyền hạn chế
- ✅ Luôn backup trước khi update
- ✅ Test trên staging trước khi deploy production

