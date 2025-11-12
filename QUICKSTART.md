# ⚡ Quick Start - Ghost CMS trên CloudPanel

Hướng dẫn nhanh deploy Ghost CMS lên CloudPanel Ubuntu 24 chỉ với vài lệnh.

---

## 🚀 Deploy trong 5 phút

### 1️⃣ SSH vào server

```bash
ssh clp@your-server-ip
cd /home/clp/htdocs/your-domain.com
```

### 2️⃣ Clone repository

```bash
# Xóa file mặc định
rm -rf * .* 2>/dev/null || true

# Clone code
git clone git@github.com:toanndmarketing/traddingview.com.vn.git .
```

### 3️⃣ Cài đặt

```bash
# Cấp quyền và chạy install
chmod +x scripts/*.sh
bash scripts/install.sh
```

### 4️⃣ Cấu hình

```bash
# Chỉnh sửa config
nano config.production.json
```

Sửa các thông tin:
- `url`: Domain của bạn
- `database`: Thông tin MySQL
- `storage.s3`: AWS S3 credentials (nếu dùng S3)

**Lưu:** `Ctrl+O` → `Enter` → `Ctrl+X`

### 5️⃣ Khởi động

```bash
# Start Ghost
bash scripts/ghost.sh start

# Lưu PM2
pm2 save
pm2 startup
```

### 6️⃣ Cấu hình Nginx trong CloudPanel

1. Vào **CloudPanel** → **Sites** → Chọn site
2. Tab **Vhost** → Thêm:

```nginx
location / {
    proxy_pass http://127.0.0.1:2368;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

3. **Save**

### 7️⃣ Truy cập

```
https://your-domain.com
https://your-domain.com/ghost
```

---

## 🔄 Update Code Mới

```bash
cd /home/clp/htdocs/your-domain.com
bash scripts/update.sh
```

---

## 🛠️ Các lệnh thường dùng

```bash
# Quản lý Ghost
bash scripts/ghost.sh start      # Khởi động
bash scripts/ghost.sh stop       # Dừng
bash scripts/ghost.sh restart    # Khởi động lại
bash scripts/ghost.sh status     # Xem trạng thái
bash scripts/ghost.sh logs       # Xem logs

# Backup
bash scripts/backup-db.sh        # Backup database

# Rollback
bash scripts/rollback.sh         # Rollback khi có lỗi
```

---

## 📋 Checklist

- [ ] SSH vào server
- [ ] Clone repository
- [ ] Chạy `bash scripts/install.sh`
- [ ] Sửa `config.production.json`
- [ ] Start Ghost
- [ ] Cấu hình Nginx reverse proxy
- [ ] Truy cập website
- [ ] Setup admin account
- [ ] `pm2 save && pm2 startup`

---

## 🐛 Lỗi thường gặp

### Ghost không start

```bash
pm2 logs ghost-tradingview
```

### Lỗi database

```bash
mysql -u username -p -h localhost database_name
```

### Lỗi permissions

```bash
chmod -R 755 content/
chown -R clp:clp content/
```

---

## 📚 Tài liệu chi tiết

- **CloudPanel:** [CLOUDPANEL.md](CLOUDPANEL.md)
- **Deployment:** [DEPLOYMENT.md](DEPLOYMENT.md)
- **Scripts:** [scripts/README.md](scripts/README.md)
- **README:** [README.md](README.md)

---

## 💡 Tips

1. **Luôn backup** trước khi update: `bash scripts/backup-db.sh`
2. **Xem logs** khi có lỗi: `bash scripts/ghost.sh logs`
3. **Monitor** Ghost: `pm2 monit`
4. **Auto-start** Ghost khi reboot: `pm2 startup`

---

**Chúc bạn deploy thành công! 🎉**

